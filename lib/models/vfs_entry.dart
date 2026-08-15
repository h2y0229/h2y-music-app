/// 가상 파일 시스템(VFS) 엔트리 모델
class VfsEntry {
  final String id;
  final String path;
  final String name;
  final int size;
  final int compressedSize;
  final int localHeaderOffset;
  final int compressionMethod;
  final bool isDirectory;
  final bool isAudio;
  final String? audioFormat;
  final bool isLyrics;
  final bool isCoverImage;

  const VfsEntry({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.compressedSize,
    required this.localHeaderOffset,
    this.compressionMethod = 8,
    required this.isDirectory,
    required this.isAudio,
    this.audioFormat,
    this.isLyrics = false,
    this.isCoverImage = false,
  });

  String get formattedSize {
    if (size <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double s = size.toDouble();
    while (s >= 1024 && i < suffixes.length - 1) {
      s /= 1024;
      i++;
    }
    return '${s.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

/// 아카이브 VFS 분석 결과 모델
class ArchiveAnalysisResult {
  final String fileName;
  final String filePath;
  final String format;
  final int totalSize;
  final int entryCount;
  final List<VfsEntry> audioTracks;
  final List<VfsEntry> lyricsFiles;
  final List<VfsEntry> coverImages;
  final int analysisTimeMs;

  const ArchiveAnalysisResult({
    required this.fileName,
    required this.filePath,
    required this.format,
    required this.totalSize,
    required this.entryCount,
    required this.audioTracks,
    required this.lyricsFiles,
    required this.coverImages,
    required this.analysisTimeMs,
  });
}
