# 📋 [Seq 005] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-001-CO: 아카이브 헤더 스캔 및 VFS 구현

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 2 | **공정**: 코어개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-07 ~ 2026-09-07 | **상태**: 대기
> **연관 산출물**: [06-세부작업목록.md](../06-세부작업목록.md) | [08-진행현황.md](../08-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-001` | **요구사항 ID**: `REQ-001`

---

## 1. 🎯 작업 목표 및 개발 범위
- ZIP, 7Z, RAR 아카이브의 Central Directory를 고속 스캔하여 디스크에 풀지 않고 인메모리 VFS 가상 트리 객체를 생성하는 엔진을 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/archive/ZipHeaderParser.ts`, `src/engine/archive/VFSTreeBuilder.ts`
* **지원 포맷**: ZIP (Deflate, Store), 7Z, TAR, RAR5 헤더 파싱

---

## 3. ✅ 작업 완료 체크리스트
- [ ] Central Directory 끝단 파싱 속도 50ms 이내 검증
- [ ] 음원 확장자 필터링 및 폴더/파일 계층 트리 정상 빌드
