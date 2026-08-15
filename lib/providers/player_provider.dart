import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../engine/audio/audio_player_handler.dart';
import '../models/vfs_entry.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayerHandler _audioHandler;

  VfsEntry? _currentPlayingTrack;
  String? _currentZipPath;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 0.8;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  VfsEntry? get currentPlayingTrack => _currentPlayingTrack;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;

  PlayerProvider(this._audioHandler) {
    _initListeners();
  }

  void _initListeners() {
    _audioHandler.player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioHandler.player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _audioHandler.player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioHandler.player.volumeStream.listen((vol) {
      _volume = vol;
      notifyListeners();
    });
  }

  Future<void> playTrack(String zipPath, VfsEntry track) async {
    _currentZipPath = zipPath;
    _currentPlayingTrack = track;
    notifyListeners();

    try {
      await _audioHandler.playVfsTrack(zipPath, track);
    } catch (e) {
      debugPrint('트랙 재생 실패: $e');
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioHandler.setVolume(_volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleLoopMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    _audioHandler.player.setLoopMode(_loopMode);
    notifyListeners();
  }

  Future<void> nextTrack(List<VfsEntry> tracks) async {
    if (tracks.isEmpty || _currentPlayingTrack == null || _currentZipPath == null) return;
    final currentIndex = tracks.indexWhere((t) => t.id == _currentPlayingTrack!.id);
    if (currentIndex >= 0 && currentIndex < tracks.length - 1) {
      await playTrack(_currentZipPath!, tracks[currentIndex + 1]);
    } else if (_loopMode == LoopMode.all && tracks.isNotEmpty) {
      await playTrack(_currentZipPath!, tracks.first);
    }
  }

  Future<void> prevTrack(List<VfsEntry> tracks) async {
    if (tracks.isEmpty || _currentPlayingTrack == null || _currentZipPath == null) return;
    final currentIndex = tracks.indexWhere((t) => t.id == _currentPlayingTrack!.id);
    if (currentIndex > 0) {
      await playTrack(_currentZipPath!, tracks[currentIndex - 1]);
    }
  }
}
