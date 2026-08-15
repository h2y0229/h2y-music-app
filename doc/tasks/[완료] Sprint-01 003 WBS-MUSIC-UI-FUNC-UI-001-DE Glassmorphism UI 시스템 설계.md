# 📋 [Seq 003] WBS-MUSIC-UI-FUNC-UI-001-DE: Glassmorphism UI 시스템 설계

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 1 | **공정**: 화면설계(`DE`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-03 ~ 2026-09-03 | **상태**: 완료
> **연관 산출물**: [07-세부작업목록.md](../07-세부작업목록.md) | [09-진행현황.md](../09-진행현황.md) | **기능 ID**: `FUNC-UI-001` | **요구사항 ID**: `REQ-010`

---

## 1. 🎯 작업 목표 및 개발 범위
- 프리미엄 Glassmorphism 다크 테마 디자인 시스템, CSS 컬러 토큰, 반투명 블러 레이아웃 및 3단 반응형 UI(트랙트리-메인뷰-재생바) 구조를 설계하고 구현합니다.

---

## 2. 🛠️ 세부 구현 사양
* **스타일 토큰**: `src/styles/tokens.css` (색상, 블러, 그라디언트, 타이포그래피 토큰)
* **글래스모피즘 유틸리티**: `src/styles/glassmorphism.css` (패널, 아크릴 카드, 네온 배지, 버튼)
* **반응형 3단 레이아웃**: `src/styles/layout.css` (사이드바, 메인 비주얼라이저, 하단 재생바)
* **통합 스타일**: `src/style.css`

---

## 3. 🗄️ 토큰 명세
```css
:root {
  --bg-app: #07080d;
  --bg-surface-1: #0d0f18;
  --glass-base: rgba(18, 22, 36, 0.65);
  --glass-border: rgba(255, 255, 255, 0.09);
  --glass-blur-md: blur(24px);
  --accent-cyan: #00f0ff;
  --accent-purple: #a855f7;
  --gradient-accent: linear-gradient(135deg, #00f0ff 0%, #a855f7 50%, #ec4899 100%);
}
```

---

## 4. ✅ 작업 완료 체크리스트 (Definition of Done)
- [x] CSS 디자인 토큰 및 HSL/HEX 색상 체계 정의 완료 (`src/styles/tokens.css`)
- [x] Glassmorphism 아크릴 패널 및 네온 글로우 스타일 구현 완료 (`src/styles/glassmorphism.css`)
- [x] 반응형 3단 그리드 레이아웃 명세 및 반응형 브레이크포인트 구현 완료 (`src/styles/layout.css`)
- [x] Pretendard, Inter, JetBrains Mono 웹 폰트 로드 환경 구성 완료

---

## 5. 📝 개발자 노트 및 이슈 사항
- `backdrop-filter`와 반투명 경계선(`border: 1px solid rgba(255,255,255,0.09)`)을 조화시켜 데스크톱 앱 수준의 깊이감과 일체감을 제공함.
