# 📋 [Seq 002] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-002-DE: 메모리 스트리밍 및 Worker 설계

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 1 | **공정**: 아키텍처설계(`DE`) | **배분 공수**: 0.5 M/D
> **일정**: 2026-09-02 ~ 2026-09-02 | **상태**: 대기
> **연관 산출물**: [06-세부작업목록.md](../06-세부작업목록.md) | [08-진행현황.md](../08-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-002` | **요구사항 ID**: `REQ-002`

---

## 1. 🎯 작업 목표 및 개발 범위
- UI 스레드 블로킹을 방지하기 위한 Web Worker 기반 온디맨드 청크 스트리밍 아키텍처 및 Worker-메인스레드 간 Transferable ArrayBuffer 메시징 파이프라인을 설계합니다.

---

## 2. 🛠️ 세부 구현 사양
### 2.1 대상 파일
* `src/workers/ArchiveStreamWorker.ts`, `src/engine/archive/WorkerBridge.ts`
### 2.2 설계 사양
- Worker 메시지 프로토콜 (`INIT`, `EXTRACT_CHUNK`, `CANCEL`, `PROGRESS`) 정의

---

## 3. 🗄️ 인터페이스 명세
```typescript
export interface WorkerRequest {
  type: 'EXTRACT_CHUNK';
  fileHandle: File | Blob;
  offset: number;
  length: number;
  trackId: string;
}
```

---

## 4. ✅ 작업 완료 체크리스트
- [ ] Web Worker 메시징 규격 정의 완료
- [ ] Transferable Object 메모리 제로카피 전송 설계 완료
