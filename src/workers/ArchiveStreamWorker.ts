/**
 * @file ArchiveStreamWorker.ts
 * @description 백그라운드 Web Worker 기반 온디맨드 아카이브 오디오 청크 추출기
 */

import { inflateSync } from 'fflate';
import { ExtractChunkPayload, WorkerRequestMessage, WorkerResponseMessage } from '../types/worker';

// Worker 컨텍스트 전역 선언
const ctx: DedicatedWorkerGlobalScope = self as unknown as DedicatedWorkerGlobalScope;

let isCancelled = false;

ctx.addEventListener('message', async (event: MessageEvent<WorkerRequestMessage>) => {
  const { id, action, payload } = event.data;

  if (action === 'PING') {
    ctx.postMessage({ id, status: 'PONG' } as WorkerResponseMessage);
    return;
  }

  if (action === 'CANCEL') {
    isCancelled = true;
    ctx.postMessage({
      id,
      status: 'COMPLETE',
      error: '작업이 사용자에 의해 취소되었습니다.'
    } as WorkerResponseMessage);
    return;
  }

  if (action === 'EXTRACT_CHUNK' && payload) {
    isCancelled = false;
    const startTime = performance.now();
    const extractPayload = payload as ExtractChunkPayload;

    try {
      const { file, localHeaderOffset, compressedSize, trackId } = extractPayload;

      // 1. Local File Header 읽기 (최소 30바이트)
      const headerSlice = file.slice(localHeaderOffset, localHeaderOffset + 30);
      const headerBuffer = await headerSlice.arrayBuffer();
      const headerView = new DataView(headerBuffer);

      const sig = headerView.getUint32(0, true);
      if (sig !== 0x04034b50) {
        throw new Error(`유효하지 않은 Local File Header 시그니처: 0x${sig.toString(16)}`);
      }

      const compressionMethod = headerView.getUint16(8, true);
      const fileNameLen = headerView.getUint16(26, true);
      const extraFieldLen = headerView.getUint16(28, true);

      // 2. 실제 압축 데이터 오프셋 계산
      const dataOffset = localHeaderOffset + 30 + fileNameLen + extraFieldLen;
      const dataSlice = file.slice(dataOffset, dataOffset + compressedSize);
      const rawDataBuffer = await dataSlice.arrayBuffer();
      const rawBytes = new Uint8Array(rawDataBuffer);

      let extractedBuffer: ArrayBuffer;

      // 3. 압축 방식에 따른 디코딩
      if (compressionMethod === 0) {
        // STORED (무압축)
        extractedBuffer = rawBytes.buffer;
      } else if (compressionMethod === 8) {
        // DEFLATE 압축
        if (isCancelled) return;
        const decompressedBytes = inflateSync(rawBytes);
        extractedBuffer = decompressedBytes.buffer;
      } else {
        throw new Error(`지원하지 않는 압축 방식입니다: method=${compressionMethod}`);
      }

      const endTime = performance.now();

      // 4. Transferable Object 제로카피 전송
      const response: WorkerResponseMessage = {
        id,
        status: 'CHUNK_DATA',
        trackId,
        data: extractedBuffer,
        executionTimeMs: Math.round(endTime - startTime)
      };

      ctx.postMessage(response, [extractedBuffer]);

    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : '오디오 청크 추출 중 알 수 없는 에러가 발생했습니다.';
      ctx.postMessage({
        id,
        status: 'ERROR',
        error: errorMessage
      } as WorkerResponseMessage);
    }
  }
});
