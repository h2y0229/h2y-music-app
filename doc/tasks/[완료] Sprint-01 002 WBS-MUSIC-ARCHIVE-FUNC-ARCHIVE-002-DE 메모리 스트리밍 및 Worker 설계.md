# 📋 [Seq 002] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-002-DE: 메모리 스트리밍 및 Worker 설계

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 1 | **공정**: 아키텍처설계(`DE`) | **배분 공수**: 0.5 M/D
> **일정**: 2026-09-02 ~ 2026-09-02 | **상태**: 완료
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-002` | **요구사항 ID**: `REQ-002`

---

## 1. 🎯 작업 목표 및 개발 범위
- UI 스레드 블로킹을 방지하기 위한 Web Worker 기반 온디맨드 청크 스트리밍 아키텍처 및 Worker-메인스레드 간 Transferable ArrayBuffer 메시징 파이프라인을 설계하고 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
### 2.1 대상 파일
* `src/types/worker.ts`: Worker 요청/응답 메시징 프로토콜 및 인터페이스
* `src/workers/ArchiveStreamWorker.ts`: Transferable ArrayBuffer 기반 백그라운드 디플레이트 Worker
* `src/engine/archive/WorkerBridge.ts`: 메인 스레드 비동기 RPC 통신 브리지

### 2.2 설계 사양
- Worker 메시지 프로토콜 (`INIT`, `EXTRACT_CHUNK`, `CANCEL`, `PING`, `CHUNK_DATA`, `ERROR`) 정의
- Zero-copy Transferable ArrayBuffer 전송을 통한 메인 UI 스레드 60fps 유지 보장

---

## 3. 🗄️ 인터페이스 명세
```typescript
export interface ExtractChunkPayload {
  trackId: string;
  localHeaderOffset: number;
  compressedSize: number;
  uncompressedSize: number;
  format: string;
  file: File | Blob;
}

export interface WorkerResponseMessage {
  id: string;
  status: WorkerResponseStatus;
  trackId?: string;
  data?: ArrayBuffer;
  error?: string;
  executionTimeMs?: number;
}
```

---

## 4. ✅ 작업 완료 체크리스트 (Definition of Done)
- [x] Web Worker 메시징 규격 정의 완료 (`src/types/worker.ts`)
- [x] Transferable Object 메모리 제로카피 전송 설계 및 Worker 구현 완료 (`src/workers/ArchiveStreamWorker.ts`)
- [x] 메인 스레드 비동기 RPC 브리지 구현 완료 (`src/engine/archive/WorkerBridge.ts`)
- [x] **사용 라이브러리 및 오픈소스 라이선스 적합성 검증 완료** (상용 배포 가능 여부 및 GPL 감염 위험 배제)
- [x] Web Worker 빌드 및 번들링 정상 동작 검증 완료

---

## 5. 📝 개발자 노트 및 이슈 사항
- Vite 환경에서 `new Worker(new URL(..., import.meta.url), { type: 'module' })`를 통해 번들러 호환 ESM Worker 로딩 구조를 확립함.
