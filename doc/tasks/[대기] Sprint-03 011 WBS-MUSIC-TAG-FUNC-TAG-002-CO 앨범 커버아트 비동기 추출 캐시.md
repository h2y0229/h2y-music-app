# 📋 [Seq 011] WBS-MUSIC-TAG-FUNC-TAG-002-CO: 앨범 커버아트 비동기 추출 캐시

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 3 | **공정**: 태그개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-15 ~ 2026-09-15 | **상태**: 대기
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-TAG-002` | **요구사항 ID**: `REQ-005`

---

## 1. 🎯 작업 목표 및 개발 범위
- 음원 내장 APIC(Attached Picture) 프레임 바이너리 및 아카이브 폴더 내 `cover.jpg`, `folder.png` 이미지를 비동기 추출하여 메모리 Blob URL을 생성하고 UI 배경 블러에 동적으로 바인딩합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/tag/AlbumArtExtractor.ts`, `src/engine/storage/BlobCache.ts`

---

## 3. ✅ 작업 완료 체크리스트 (Definition of Done)
- [ ] 내장 앨범아트 및 폴더 커버 이미지 추출 정상 동작
- [ ] 이전 앨범아트 Object URL 자동 해제(Revoke) 메모리 누수 방지
- [ ] **사용 라이브러리 및 오픈소스 라이선스 적합성 검증 완료** (상용 배포 가능 여부, 소스코드 강제공개(GPL/AGPL 등) 위험 배제, 라이선스 고지 의무 확인)
