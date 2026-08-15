/**
 * @file WorkerBridge.ts
 * @description 메인 UI 스레드와 Web Worker 간 비동기 RPC 통신 브리지
 */

import { ExtractChunkPayload, WorkerRequestMessage, WorkerResponseMessage } from '../../types/worker';

export class WorkerBridge {
  private worker: Worker | null = null;
  private pendingRequests = new Map<string, {
    resolve: (data: ArrayBuffer) => void;
    reject: (err: Error) => void;
  }>();
  private reqSequence = 0;

  constructor() {
    this.initWorker();
  }

  /** Worker 인스턴스 생성 및 메시지 핸들러 바인딩 */
  private initWorker(): void {
    try {
      this.worker = new Worker(
        new URL('../../workers/ArchiveStreamWorker.ts', import.meta.url),
        { type: 'module' }
      );

      this.worker.onmessage = (event: MessageEvent<WorkerResponseMessage>) => {
        const { id, status, data, error } = event.data;
        const pending = this.pendingRequests.get(id);

        if (!pending) return;

        if (status === 'CHUNK_DATA' && data) {
          pending.resolve(data);
          this.pendingRequests.delete(id);
        } else if (status === 'ERROR') {
          pending.reject(new Error(error || 'Worker 처리 중 오류가 발생했습니다.'));
          this.pendingRequests.delete(id);
        } else if (status === 'COMPLETE') {
          this.pendingRequests.delete(id);
        }
      };

      this.worker.onerror = (error) => {
        console.error('Worker 오류 발생:', error);
      };
    } catch (e) {
      console.warn('Web Worker 초기화 실패 (Fallback 필요):', e);
    }
  }

  /**
   * 지정한 파일 및 오프셋으로부터 오디오 청크를 비동기 추출합니다.
   */
  public async extractAudioChunk(payload: ExtractChunkPayload): Promise<ArrayBuffer> {
    if (!this.worker) {
      throw new Error('Worker 인스턴스가 활성화되어 있지 않습니다.');
    }

    const id = `req-${++this.reqSequence}-${Date.now()}`;

    return new Promise<ArrayBuffer>((resolve, reject) => {
      this.pendingRequests.set(id, { resolve, reject });

      const request: WorkerRequestMessage = {
        id,
        action: 'EXTRACT_CHUNK',
        payload
      };

      this.worker?.postMessage(request);
    });
  }

  /**
   * 진행 중인 추출 작업을 취소합니다.
   */
  public cancelAll(): void {
    if (!this.worker) return;

    const id = `cancel-${Date.now()}`;
    const request: WorkerRequestMessage = {
      id,
      action: 'CANCEL'
    };

    this.worker.postMessage(request);
    this.pendingRequests.forEach(({ reject }) => {
      reject(new Error('작업이 취소되었습니다.'));
    });
    this.pendingRequests.clear();
  }

  /** Worker 리소스 정리 */
  public terminate(): void {
    if (this.worker) {
      this.worker.terminate();
      this.worker = null;
    }
    this.pendingRequests.clear();
  }
}
