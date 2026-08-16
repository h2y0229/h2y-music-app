# 📋 [Seq 015] WBS-MUSIC-AUDIO-FUNC-AUDIO-003-CO: 10밴드 EQ 및 DSP 오디오 필터

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 4 | **공정**: 오디오DSP개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-21 ~ 2026-09-21 | **상태**: 대기
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-AUDIO-003` | **요구사항 ID**: `REQ-009`

---

## 1. 🎯 작업 목표 및 개발 범위
- Web Audio `BiquadFilterNode` 체인을 통해 32Hz~16kHz 10개 주파수 대역 게인을 제어하고 장르별 프리셋(Pop, Rock, Classic, BassBoost 등) 및 Canvas 60fps 오디오 스펙트럼 비주얼라이저를 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/audio/EqualizerEngine.ts`, `src/components/SpectrumVisualizer.ts`

---

## 3. ✅ 작업 완료 체크리스트 (Definition of Done)
- [ ] 10밴드 필터 노드 체인 연결 및 게인 슬라이더 연동
- [ ] AnalyserNode 주파수 데이터 기반 60fps 부드러운 Canvas 렌더링
- [ ] **사용 라이브러리 및 오픈소스 라이선스 적합성 검증 완료** (상용 배포 가능 여부, 소스코드 강제공개(GPL/AGPL 등) 위험 배제, 라이선스 고지 의무 확인)
