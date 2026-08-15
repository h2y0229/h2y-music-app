/**
 * @file ArchiveAnalyzer.ts
 * @description 압축 파일 바이너리 헤더 분석, 매직 넘버 식별 및 VFS 가상 트리 구축 엔진
 */

import { ArchiveAnalysisResult, ArchiveFormat, AudioFormat, VFSEntry, VFSTreeNode } from '../../types/vfs';

export class ArchiveAnalyzer {
  private static readonly AUDIO_EXTENSIONS = new Set<string>(['mp3', 'flac', 'wav', 'aac', 'ogg', 'm4a', 'opus']);
  private static readonly IMAGE_EXTENSIONS = new Set<string>(['jpg', 'jpeg', 'png', 'webp', 'gif']);
  private static readonly LYRICS_EXTENSIONS = new Set<string>(['lrc', 'txt']);

  /**
   * 파일의 시작 바이트(Magic Number)를 분석하여 압축 포맷을 판별합니다.
   * @param file 분석할 파일 (File 또는 Blob)
   */
  public static async detectFormat(file: File | Blob): Promise<ArchiveFormat> {
    const headerSlice = file.slice(0, 16);
    const buffer = await headerSlice.arrayBuffer();
    const bytes = new Uint8Array(buffer);

    // 1. ZIP: PK\x03\x04 (0x50, 0x4B, 0x03, 0x04)
    if (bytes[0] === 0x50 && bytes[1] === 0x4b && (bytes[2] === 0x03 || bytes[2] === 0x05 || bytes[2] === 0x07)) {
      return 'zip';
    }

    // 2. 7-Zip: 7z\xBC\xAF\x27\x1C (0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C)
    if (bytes[0] === 0x37 && bytes[1] === 0x7a && bytes[2] === 0xbc && bytes[3] === 0xaf && bytes[4] === 0x27 && bytes[5] === 0x1c) {
      return '7z';
    }

    // 3. RAR: Rar!\x1A\x07 (0x52, 0x61, 0x72, 0x21, 0x1A, 0x07)
    if (bytes[0] === 0x52 && bytes[1] === 0x61 && bytes[2] === 0x72 && bytes[3] === 0x21 && bytes[4] === 0x1a && bytes[5] === 0x07) {
      return 'rar';
    }

    // 4. TAR: 257바이트 오프셋의 'ustar' 확인
    if (file.size >= 512) {
      const tarSlice = file.slice(257, 262);
      const tarBuffer = await tarSlice.arrayBuffer();
      const tarBytes = new Uint8Array(tarBuffer);
      const magic = String.fromCharCode(...tarBytes);
      if (magic === 'ustar') {
        return 'tar';
      }
    }

    return 'unknown';
  }

  /**
   * ZIP 파일의 끝단 EOCD(End of Central Directory) 및 Central Directory를 Range Read하여
   * 디스크에 풀지 않고 고속으로 VFS 인덱스를 구축합니다.
   */
  public static async analyzeZip(file: File | Blob): Promise<ArchiveAnalysisResult> {
    const startTime = performance.now();
    const fileSize = file.size;

    // EOCD는 최대 65,557바이트 (EOCD 크기 22 + 코멘트 최대 65535)
    const readSize = Math.min(fileSize, 65557);
    const tailSlice = file.slice(fileSize - readSize, fileSize);
    const tailBuffer = await tailSlice.arrayBuffer();
    const tailBytes = new Uint8Array(tailBuffer);
    const view = new DataView(tailBuffer);

    // 역방향으로 EOCD 시그니처 (0x06054B50) 탐색
    let eocdOffset = -1;
    for (let i = readSize - 22; i >= 0; i--) {
      if (tailBytes[i] === 0x50 && tailBytes[i + 1] === 0x4b && tailBytes[i + 2] === 0x05 && tailBytes[i + 3] === 0x06) {
        eocdOffset = i;
        break;
      }
    }

    if (eocdOffset === -1) {
      throw new Error('유효한 ZIP End of Central Directory(EOCD) 레코드를 찾을 수 없습니다.');
    }

    const cdTotalEntries = view.getUint16(eocdOffset + 10, true);
    const cdSize = view.getUint32(eocdOffset + 12, true);
    const cdOffset = view.getUint32(eocdOffset + 16, true);

    // Central Directory 블록만 Range Read
    const cdSlice = file.slice(cdOffset, cdOffset + cdSize);
    const cdBuffer = await cdSlice.arrayBuffer();
    const cdView = new DataView(cdBuffer);

    const entriesMap = new Map<string, VFSEntry>();
    const audioTracks: VFSEntry[] = [];
    const lyricsFiles: VFSEntry[] = [];
    const coverImages: VFSEntry[] = [];

    const decoder = new TextDecoder('utf-8');
    let ptr = 0;

    for (let entryIdx = 0; entryIdx < cdTotalEntries && ptr + 46 <= cdSize; entryIdx++) {
      const sig = cdView.getUint32(ptr, true);
      if (sig !== 0x02014b50) {
        // Central Directory Header 시그니처 불일치
        break;
      }

      const compressedSize = cdView.getUint32(ptr + 20, true);
      const uncompressedSize = cdView.getUint32(ptr + 24, true);
      const fileNameLen = cdView.getUint16(ptr + 28, true);
      const extraLen = cdView.getUint16(ptr + 30, true);
      const commentLen = cdView.getUint16(ptr + 32, true);
      const localHeaderOffset = cdView.getUint32(ptr + 42, true);

      const fileNameBytes = new Uint8Array(cdBuffer, ptr + 46, fileNameLen);
      let fileName = decoder.decode(fileNameBytes);

      // Windows 스타일 경로 구분자 통일
      fileName = fileName.replace(/\\/g, '/');

      const isDirectory = fileName.endsWith('/') || uncompressedSize === 0;
      const cleanPath = fileName.endsWith('/') ? fileName.slice(0, -1) : fileName;
      const name = cleanPath.split('/').pop() || cleanPath;

      const ext = name.split('.').pop()?.toLowerCase() || '';
      const isAudio = !isDirectory && this.AUDIO_EXTENSIONS.has(ext);
      const isLyrics = !isDirectory && this.LYRICS_EXTENSIONS.has(ext);
      const isCoverImage = !isDirectory && (this.IMAGE_EXTENSIONS.has(ext) && (name.toLowerCase().includes('cover') || name.toLowerCase().includes('folder') || name.toLowerCase().includes('front') || name.toLowerCase().includes('art')));

      const entry: VFSEntry = {
        id: `vfs-${entryIdx + 1}-${name}`,
        path: cleanPath,
        name,
        size: uncompressedSize,
        compressedSize,
        offset: localHeaderOffset,
        isDirectory,
        isAudio,
        audioFormat: isAudio ? (ext as AudioFormat) : undefined,
        isLyrics,
        isCoverImage
      };

      entriesMap.set(cleanPath, entry);

      if (isAudio) audioTracks.push(entry);
      if (isLyrics) lyricsFiles.push(entry);
      if (isCoverImage) coverImages.push(entry);

      ptr += 46 + fileNameLen + extraLen + commentLen;
    }

    const rootNode = this.buildVFSTree(Array.from(entriesMap.values()));
    const endTime = performance.now();

    return {
      format: 'zip',
      totalSize: fileSize,
      entryCount: entriesMap.size,
      audioTracks,
      lyricsFiles,
      coverImages,
      entriesMap,
      rootNode,
      analysisTimeMs: Math.round(endTime - startTime)
    };
  }

  /**
   * 평탄화된 엔트리 목록으로부터 VFS 계층형 디렉토리 트리를 생성합니다.
   */
  public static buildVFSTree(entries: VFSEntry[]): VFSTreeNode {
    const root: VFSTreeNode = {
      name: 'root',
      path: '',
      isDirectory: true,
      children: new Map()
    };

    for (const entry of entries) {
      const parts = entry.path.split('/');
      let current = root;

      for (let i = 0; i < parts.length; i++) {
        const part = parts[i];
        if (!part) continue;

        const isLast = i === parts.length - 1;
        if (!current.children.has(part)) {
          const isDir = isLast ? entry.isDirectory : true;
          const node: VFSTreeNode = {
            name: part,
            path: parts.slice(0, i + 1).join('/'),
            isDirectory: isDir,
            entry: isLast ? entry : undefined,
            children: new Map()
          };
          current.children.set(part, node);
        }
        current = current.children.get(part)!;
      }
    }

    return root;
  }
}
