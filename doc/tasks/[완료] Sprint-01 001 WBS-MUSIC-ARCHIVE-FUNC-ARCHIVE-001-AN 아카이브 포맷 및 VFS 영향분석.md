# 📋 [Seq 001] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-001-AN: 아카이브 포맷 및 VFS 영향분석

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 1 | **공정**: 요구사항분석(`AN`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-01 ~ 2026-09-01 | **상태**: 완료
> **연관 산출물**: [06-세부작업목록.md](../06-세부작업목록.md) | [08-진행현황.md](../08-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-001` | **요구사항 ID**: `REQ-001`

---

## 1. 🎯 작업 목표 및 개발 범위
- ZIP, 7Z, RAR, TAR 아카이브 파일의 바이너리 헤더 구조(Central Directory, End of Central Directory Record)를 정밀 분석하고, 디스크 해제 없이 인메모리 가상 파일 시스템(VFS) 트리 구조를 구축하기 위한 영향분석 및 아키텍처 전략을 수립합니다.

---

## 2. 🛠️ 세부 구현 사양

### 2.1 대상 파일 및 컴포넌트
* **타입 정의**: `src/types/vfs.ts`
* **코어 엔진**: `src/engine/archive/ArchiveAnalyzer.ts`
* **문서 산출물**: `doc/04-아키텍처.md`

### 2.2 UI 화면 / 기능 명세
- 아카이브 포맷별 매직 넘버(Magic Number: ZIP `PK\x03\x04`, 7Z `7z\xBC\xAF`, RAR `Rar!\x1A\x07`, TAR `ustar`) 식별 알고리즘 구현
- 대용량 파일에서 끝단 EOCD(64KB) 및 Central Directory만 Range Read하는 초고속 VFS 인덱싱 알고리즘 구현
- 계층형 가상 디렉토리 트리 노드(`VFSTreeNode`) 자동 빌드 파이프라인 완성

---

## 3. 🗄️ 인터페이스 및 연관 명세
* **VFS 엔트리 인터페이스 (`src/types/vfs.ts`)**:
  ```typescript
  export interface VFSEntry {
    id: string;
    path: string;
    name: string;
    size: number;
    compressedSize: number;
    offset: number;
    isDirectory: boolean;
    isAudio: boolean;
    audioFormat?: AudioFormat;
    isLyrics?: boolean;
    isCoverImage?: boolean;
  }
  ```

---

## 4. ✅ 작업 완료 체크리스트 (Definition of Done)
- [x] ZIP/7Z/RAR 포맷별 Magic Number 및 Central Directory 헤더 구조 분석서 작성 완료
- [x] VFS 가상 트리 노드 데이터 모델(`VFSEntry`, `VFSTreeNode`) 정의 완료
- [x] 대용량 파일 Range Read 최적화 알고리즘(`analyzeZip`) 구현 완료
- [x] Node LTS(v20+) 환경 및 Vite + TypeScript 개발 환경 구성 완료

---

## 5. 📝 개발자 노트 및 이슈 사항
- 브라우저 File API의 `slice()` 메서드를 활용하여 끝단 64KB 영역을 우선 읽는 Range Read 방식을 적용하여 수 기가바이트(GB) 파일에서도 수십 밀리초(ms) 내에 인덱싱이 완료됨을 확인함.
