# 📋 [Seq 007] WBS-MUSIC-AUDIO-FUNC-AUDIO-001-CO: Web Audio 멀티 코덱 PCM 디코더

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 2 | **공정**: 오디오코어개발(`CO`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-09 ~ 2026-09-09 | **상태**: 대기
> **연관 산출물**: [06-세부작업목록.md](../06-세부작업목록.md) | [08-진행현황.md](../08-진행현황.md) | **기능 ID**: `FUNC-AUDIO-001` | **요구사항 ID**: `REQ-003`

---

## 1. 🎯 작업 목표 및 개발 범위
- Web Audio API `AudioContext.decodeAudioData` 및 WASM 코덱(FLAC/OGG)을 연동하여 스트리밍 수신된 바이너리 버퍼를 PCM AudioBuffer로 디코딩하는 파이프라인을 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
* **파일**: `src/engine/audio/AudioDecoder.ts`, `src/engine/audio/WebAudioPipeline.ts`
* **지원 코덱**: MP3, FLAC, WAV, AAC, OGG, M4A

---

## 3. ✅ 작업 완료 체크리스트
- [ ] MP3/FLAC/WAV 파일 PCM 디코딩 및 샘플레이트 변환 정상 동작
- [ ] 디코딩 실패 시 Graceful 에러 핸들링
