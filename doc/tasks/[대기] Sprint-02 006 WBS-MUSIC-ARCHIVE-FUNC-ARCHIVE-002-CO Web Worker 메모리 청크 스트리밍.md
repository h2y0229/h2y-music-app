# 📋 [Seq 006] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-002-CO: Web Worker 메모리 청크 스트리밍

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 2 | **공정**: 코어개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-08 ~ 2026-09-08 | **상태**: 대기
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-002` | **요구사항 ID**: `REQ-002`

---

## 1. 🎯 작업 목표 및 개발 범위
- 선택한 음원 트랙의 압축 청크 바이트만 백그라운드 Worker 스레드에서 메모리로 부분 압축 해제하고 ArrayBuffer 스트림으로 공급하는 파이프라인을 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/workers/ArchiveStreamWorker.ts`, `src/engine/archive/ChunkStreamer.ts`
* **방식**: fflate WASM / In-Memory Decompress

---

## 3. ✅ 작업 완료 체크리스트 (Definition of Done)
- [ ] 메인 스레드 렌더링 랙(Jank) 없이 백그라운드 스트리밍 추출 확인
- [ ] Transferable ArrayBuffer 전달 정상 동작
- [ ] **사용 라이브러리 및 오픈소스 라이선스 적합성 검증 완료** (상용 배포 가능 여부, 소스코드 강제공개(GPL/AGPL 등) 위험 배제, 라이선스 고지 의무 확인)
