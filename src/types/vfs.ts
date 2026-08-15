/**
 * @file vfs.ts
 * @description 가상 파일 시스템(VFS) 및 아카이브 포맷 인터페이스 정의
 */

/** 지원하는 아카이브 포맷 */
export type ArchiveFormat = 'zip' | '7z' | 'rar' | 'tar' | 'unknown';

/** 지원하는 오디오 포맷 */
export type AudioFormat = 'mp3' | 'flac' | 'wav' | 'aac' | 'ogg' | 'm4a' | 'opus';

/** VFS 엔트리 (가상 파일/디렉토리 노드) */
export interface VFSEntry {
  /** 고유 식별자 */
  id: string;
  /** 가상 전체 경로 (예: "AlbumName/Disc1/01-Track.flac") */
  path: string;
  /** 파일 또는 디렉토리 명칭 */
  name: string;
  /** 원본 비압축 크기 (bytes) */
  size: number;
  /** 압축된 크기 (bytes) */
  compressedSize: number;
  /** 아카이브 내부 데이터 오프셋 바이트 */
  offset: number;
  /** 디렉토리 여부 */
  isDirectory: boolean;
  /** 오디오 파일 여부 */
  isAudio: boolean;
  /** 오디오 확장자 포맷 */
  audioFormat?: AudioFormat;
  /** 메타데이터 (가사, 커버 이미지 등 관련 파일 여부) */
  isLyrics?: boolean;
  isCoverImage?: boolean;
}

/** VFS 디렉토리 트리 노드 */
export interface VFSTreeNode {
  name: string;
  path: string;
  isDirectory: boolean;
  entry?: VFSEntry;
  children: Map<string, VFSTreeNode>;
}

/** 아카이브 분석 결과 인터페이스 */
export interface ArchiveAnalysisResult {
  /** 식별된 아카이브 포맷 */
  format: ArchiveFormat;
  /** 전체 파일 크기 (bytes) */
  totalSize: number;
  /** 전체 엔트리 수 */
  entryCount: number;
  /** 오디오 트랙 엔트리 목록 */
  audioTracks: VFSEntry[];
  /** 동봉된 가사 파일 목록 (.lrc) */
  lyricsFiles: VFSEntry[];
  /** 동봉된 커버 이미지 목록 (cover.jpg, folder.png 등) */
  coverImages: VFSEntry[];
  /** 전체 VFS 평탄화 맵 (Path -> VFSEntry) */
  entriesMap: Map<string, VFSEntry>;
  /** VFS 가상 디렉토리 루트 노드 */
  rootNode: VFSTreeNode;
  /** 분석 소요 시간 (ms) */
  analysisTimeMs: number;
}
