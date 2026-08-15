/**
 * @file worker.ts
 * @description Web Worker 메시징 프로토콜 및 오디오 청크 스트리밍 인터페이스 정의
 */

/** Worker 요청 메시지 액션 타입 */
export type WorkerRequestAction = 'INIT' | 'EXTRACT_CHUNK' | 'CANCEL' | 'PING';

/** Worker 응답 메시지 상태 타입 */
export type WorkerResponseStatus = 'READY' | 'CHUNK_DATA' | 'COMPLETE' | 'PROGRESS' | 'PONG' | 'ERROR';

/** 오디오 청크 추출 요청 인터페이스 */
export interface ExtractChunkPayload {
  /** 트랙 고유 식별자 */
  trackId: string;
  /** 아카이브 내 Local Header 오프셋 */
  localHeaderOffset: number;
  /** 압축 데이터 바이트 크기 */
  compressedSize: number;
  /** 압축 해제 시 예상 바이트 크기 */
  uncompressedSize: number;
  /** 원본 압축 포맷 (zip, 7z 등) */
  format: string;
  /** 대상 원본 파일 (File 또는 Blob) */
  file: File | Blob;
}

/** Worker 요청 메시지 전체 구조 */
export interface WorkerRequestMessage {
  id: string;
  action: WorkerRequestAction;
  payload?: ExtractChunkPayload | { reason?: string };
}

/** Worker 응답 메시지 전체 구조 */
export interface WorkerResponseMessage {
  id: string;
  status: WorkerResponseStatus;
  trackId?: string;
  chunkIndex?: number;
  totalChunks?: number;
  progressRatio?: number;
  /** Transferable ArrayBuffer 로 전송되는 디코딩 청크 데이터 */
  data?: ArrayBuffer;
  error?: string;
  executionTimeMs?: number;
}
