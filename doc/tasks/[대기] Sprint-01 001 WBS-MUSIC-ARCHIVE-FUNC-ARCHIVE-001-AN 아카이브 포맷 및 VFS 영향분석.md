# 📋 [Seq 001] WBS-MUSIC-ARCHIVE-FUNC-ARCHIVE-001-AN: 아카이브 포맷 및 VFS 영향분석

> **과제 ID**: `PRJ-MUSIC-001` | **Sprint**: Sprint 1 | **공정**: 요구사항분석(`AN`) | **배분 공수**: 1.0 M/D
> **일정**: 2026-09-01 ~ 2026-09-01 | **상태**: 대기
> **연관 산출물**: [06-세부작업목록.md](../06-세부작업목록.md) | [08-진행현황.md](../08-진행현황.md) | **기능 ID**: `FUNC-ARCHIVE-001` | **요구사항 ID**: `REQ-001`

---

## 1. 🎯 작업 목표 및 개발 범위
- ZIP, 7Z, RAR, TAR 아카이브 파일의 바이너리 헤더 구조(Central Directory, End of Central Directory Record)를 정밀 분석하고, 디스크 해제 없이 인메모리 가상 파일 시스템(VFS) 트리 구조를 구축하기 위한 영향분석 및 아키텍처 전략을 수립합니다.

---

## 2. 🛠️ 세부 구현 사양

### 2.1 대상 파일 및 컴포넌트
* **코어 엔진**: `src/engine/archive/ArchiveAnalyzer.ts`, `src/types/vfs.ts`
* **문서 산출물**: `doc/04-아키텍처.md`

### 2.2 UI 화면 / 기능 명세
- 아카이브 포맷별 매직 넘버(Magic Number) 식별 알고리즘 정의
- 대용량 파일에서 끝단 헤더만 Range Read하는 VFS 인덱싱 사양 정의

---

## 3. 🗄️ 인터페이스 및 연관 명세
* **VFS 엔트리 인터페이스**:
  ```typescript
  export interface VFSEntry {
    id: string;
    path: string;
    name: string;
    size: number;
    compressedSize: number;
    offset: number;
    isAudio: boolean;
    format?: string;
  }
  ```

---

## 4. ✅ 작업 완료 체크리스트 (Definition of Done)
- [ ] ZIP/7Z/RAR 포맷별 Central Directory 헤더 구조 분석서 작성 완료
- [ ] VFS 가상 트리 노드 데이터 모델 정의 완료
- [ ] 대용량 파일 Range Read 전략 수립 완료

---

## 5. 📝 개발자 노트 및 이슈 사항
- 브라우저 File API의 `slice()` 메서드를 활용하여 끝단 64KB 영역을 우선 읽는 최적화 방안 검토.
