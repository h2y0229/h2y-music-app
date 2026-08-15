# 📋 [Seq 016] WBS-MUSIC-UI-FUNC-UI-002-CO: 미디어 단축키 및 시스템 세션 연동

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 4 | **공정**: 프론트엔드개발(`CO`) | **배분 공수**: 0.5 M/D
> **일정**: 2026-09-22 ~ 2026-09-22 | **상태**: 대기
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-UI-002` | **요구사항 ID**: `REQ-011`

---

## 1. 🎯 작업 목표 및 개발 범위
- 키보드 전역 단축키(Space 재생/정지, 방향키 시크/볼륨) 및 OS MediaSession API를 연동하여 시스템 알림 센터 Now Playing 컨트롤러와 하드웨어 미디어 키를 지원합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/ui/MediaSessionManager.ts`, `src/engine/ui/KeyboardShortcutHandler.ts`

---

## 3. ✅ 작업 완료 체크리스트
- [ ] OS Now Playing 컨트롤러에 트랙 정보 및 앨범아트 표출 확인
- [ ] 키보드 단축키 충돌 방지 및 정상 제어
