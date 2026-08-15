import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../engine/archive/zip_vfs_reader.dart';
import '../models/vfs_entry.dart';

class VfsProvider with ChangeNotifier {
  ArchiveAnalysisResult? _currentAnalysis;
  VfsEntry? _selectedTrack;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  ArchiveAnalysisResult? get currentAnalysis => _currentAnalysis;
  VfsEntry? get selectedTrack => _selectedTrack;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<VfsEntry> get filteredTracks {
    if (_currentAnalysis == null) return [];
    if (_searchQuery.trim().isEmpty) return _currentAnalysis!.audioTracks;

    final q = _searchQuery.toLowerCase();
    return _currentAnalysis!.audioTracks
        .where((t) => t.name.toLowerCase().contains(q) || t.path.toLowerCase().contains(q))
        .toList();
  }

  /// 네이티브 파일 선택기를 열어 ZIP 아카이브를 선택하고 VFS 인덱스를 생성합니다.
  Future<void> pickArchiveFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        await loadArchiveFromPath(result.files.single.path!);
      }
    } catch (e) {
      _errorMessage = '파일 선택 중 오류 발생: $e';
      notifyListeners();
    }
  }

  /// 지정한 경로의 아카이브 파일을 분석합니다.
  Future<void> loadArchiveFromPath(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analysis = await ZipVfsReader.analyzeZipFile(filePath);
      _currentAnalysis = analysis;

      if (analysis.audioTracks.isNotEmpty) {
        _selectedTrack = analysis.audioTracks.first;
      } else {
        _selectedTrack = null;
      }
    } catch (e) {
      _errorMessage = '아카이브 분석 실패: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTrack(VfsEntry track) {
    _selectedTrack = track;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
