# 📋 [Seq 010] WBS-MUSIC-TAG-FUNC-TAG-001-CO: ID3 Vorbis FLAC 메타데이터 파서

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 3 | **공정**: 태그개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-14 ~ 2026-09-14 | **상태**: 대기
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-TAG-001` | **요구사항 ID**: `REQ-004`

---

## 1. 🎯 작업 목표 및 개발 범위
- 음원 파일 헤더의 ID3v1/ID3v2.3/ID3v2.4, Vorbis Comment, FLAC Metadata Block을 비동기 파싱하여 곡명, 아티스트, 앨범명, 트랙 번호, 장르 정보를 추출하고 UTF-8/EUC-KR 다국어 인코딩을 자동 판별합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/tag/TagParser.ts`, `src/engine/tag/EncodingDetector.ts`

---

## 3. ✅ 작업 완료 체크리스트 (Definition of Done)
- [ ] ID3v2 한글 깨짐 없는 정상 파싱 검증
- [ ] FLAC/OGG Vorbis 코멘트 추출 확인
- [ ] **사용 라이브러리 및 오픈소스 라이선스 적합성 검증 완료** (상용 배포 가능 여부, 소스코드 강제공개(GPL/AGPL 등) 위험 배제, 라이선스 고지 의무 확인)
