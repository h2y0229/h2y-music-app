import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/vfs_entry.dart';

class ZipVfsReader {
  static const Set<String> _audioExtensions = {
    'mp3', 'flac', 'wav', 'aac', 'ogg', 'm4a', 'opus'
  };
  static const Set<String> _lyricsExtensions = {'lrc', 'txt'};
  static const Set<String> _imageExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'gif'
  };

  /// ZIP 파일의 끝단 EOCD(End of Central Directory) 및 Central Directory를
  /// 디스크에 압축 해제하지 않고 Range Read하여 초고속 VFS 인덱스를 생성합니다.
  static Future<ArchiveAnalysisResult> analyzeZipFile(String filePath) async {
    final stopwatch = Stopwatch()..start();
    final file = File(filePath);
    final fileSize = await file.length();

    final raf = await file.open(mode: FileMode.read);
    try {
      // 1. EOCD 탐색 (최대 65,557 바이트)
      final readSize = fileSize < 65557 ? fileSize : 65557;
      await raf.setPosition(fileSize - readSize);
      final tailBytes = await raf.read(readSize);
      final byteData = ByteData.sublistView(tailBytes);

      int eocdOffsetInTail = -1;
      for (int i = readSize - 22; i >= 0; i--) {
        if (tailBytes[i] == 0x50 &&
            tailBytes[i + 1] == 0x4B &&
            tailBytes[i + 2] == 0x05 &&
            tailBytes[i + 3] == 0x06) {
          eocdOffsetInTail = i;
          break;
        }
      }

      if (eocdOffsetInTail == -1) {
        throw Exception('유효한 ZIP End of Central Directory(EOCD) 레코드를 찾을 수 없습니다.');
      }

      final cdTotalEntries = byteData.getUint16(eocdOffsetInTail + 10, Endian.little);
      final cdSize = byteData.getUint32(eocdOffsetInTail + 12, Endian.little);
      final cdOffset = byteData.getUint32(eocdOffsetInTail + 16, Endian.little);

      // 2. Central Directory 블록만 Range Read
      await raf.setPosition(cdOffset);
      final cdBytes = await raf.read(cdSize);
      final cdView = ByteData.sublistView(cdBytes);

      final audioTracks = <VfsEntry>[];
      final lyricsFiles = <VfsEntry>[];
      final coverImages = <VfsEntry>[];

      int ptr = 0;
      for (int entryIdx = 0; entryIdx < cdTotalEntries && ptr + 46 <= cdSize; entryIdx++) {
        final sig = cdView.getUint32(ptr, Endian.little);
        if (sig != 0x02014B50) break;

        final compressionMethod = cdView.getUint16(ptr + 10, Endian.little);
        final compressedSize = cdView.getUint32(ptr + 20, Endian.little);
        final uncompressedSize = cdView.getUint32(ptr + 24, Endian.little);
        final fileNameLen = cdView.getUint16(ptr + 28, Endian.little);
        final extraLen = cdView.getUint16(ptr + 30, Endian.little);
        final commentLen = cdView.getUint16(ptr + 32, Endian.little);
        final localHeaderOffset = cdView.getUint32(ptr + 42, Endian.little);

        final fileNameBytes = cdBytes.sublist(ptr + 46, ptr + 46 + fileNameLen);
        String fileName;
        try {
          fileName = utf8.decode(fileNameBytes);
        } catch (_) {
          fileName = latin1.decode(fileNameBytes);
        }
        fileName = fileName.replaceAll('\\', '/');

        final isDirectory = fileName.endsWith('/') || uncompressedSize == 0;
        final cleanPath = fileName.endsWith('/') ? fileName.substring(0, fileName.length - 1) : fileName;
        final name = cleanPath.split('/').last;
        final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';

        final isAudio = !isDirectory && _audioExtensions.contains(ext);
        final isLyrics = !isDirectory && _lyricsExtensions.contains(ext);
        final isCoverImage = !isDirectory &&
            _imageExtensions.contains(ext) &&
            (name.toLowerCase().contains('cover') ||
                name.toLowerCase().contains('folder') ||
                name.toLowerCase().contains('front') ||
                name.toLowerCase().contains('art'));

        final entry = VfsEntry(
          id: 'vfs-${entryIdx + 1}-$name',
          path: cleanPath,
          name: name,
          size: uncompressedSize,
          compressedSize: compressedSize,
          localHeaderOffset: localHeaderOffset,
          compressionMethod: compressionMethod,
          isDirectory: isDirectory,
          isAudio: isAudio,
          audioFormat: isAudio ? ext : null,
          isLyrics: isLyrics,
          isCoverImage: isCoverImage,
        );

        if (isAudio) audioTracks.push(entry);
        if (isLyrics) lyricsFiles.push(entry);
        if (isCoverImage) coverImages.push(entry);

        ptr += 46 + fileNameLen + extraLen + commentLen;
      }

      stopwatch.stop();

      return ArchiveAnalysisResult(
        fileName: file.path.split('/').last,
        filePath: filePath,
        format: 'zip',
        totalSize: fileSize,
        entryCount: audioTracks.length + lyricsFiles.length + coverImages.length,
        audioTracks: audioTracks,
        lyricsFiles: lyricsFiles,
        coverImages: coverImages,
        analysisTimeMs: stopwatch.elapsedMilliseconds,
      );
    } finally {
      await raf.close();
    }
  }

  /// 아카이브 내 특정 오디오 트랙 데이터만 디스크 해제 없이 온디맨드 추출합니다.
  static Future<Uint8List> extractAudioChunk(String zipFilePath, VfsEntry entry) async {
    final file = File(zipFilePath);
    final raf = await file.open(mode: FileMode.read);

    try {
      // 1. Local File Header 읽기
      await raf.setPosition(entry.localHeaderOffset);
      final headerBytes = await raf.read(30);
      final headerView = ByteData.sublistView(headerBytes);

      final sig = headerView.getUint32(0, Endian.little);
      if (sig != 0x04034B50) {
        throw Exception('유효하지 않은 Local File Header 시그니처: 0x${sig.toRadixString(16)}');
      }

      final fileNameLen = headerView.getUint16(26, Endian.little);
      final extraLen = headerView.getUint16(28, Endian.little);

      // 2. 실제 압축 데이터 위치 계산 및 읽기
      final dataOffset = entry.localHeaderOffset + 30 + fileNameLen + extraLen;
      await raf.setPosition(dataOffset);
      final compressedData = await raf.read(entry.compressedSize);

      // 3. 압축 방식에 따른 디코딩
      if (entry.compressionMethod == 0) {
        // STORED (무압축)
        return compressedData;
      } else if (entry.compressionMethod == 8) {
        // DEFLATE 압축
        final decompressed = Inflate(compressedData).getBytes();
        return Uint8List.fromList(decompressed);
      } else {
        throw Exception('지원하지 않는 압축 방식입니다: method=${entry.compressionMethod}');
      }
    } finally {
      await raf.close();
    }
  }
}

extension _ListPush<T> on List<T> {
  void push(T item) => add(item);
}
