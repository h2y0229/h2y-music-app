import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../archive/archive_stream_source.dart';
import '../../models/vfs_entry.dart';
import '../archive/zip_vfs_reader.dart';

/// Android 및 iOS 백그라운드 오디오 및 잠금화면 미디어 세션 제어 핸들러
class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  AudioPlayerHandler() {
    _initListeners();
  }

  void _initListeners() {
    // 1. 재생 상태 변경 브로드캐스팅
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });

    // 2. 곡 재생 완료 시 다음 곡 자동 재생
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  /// ZIP 아카이브에서 트랙을 추출하여 즉시 메모리 스트리밍 재생합니다.
  Future<void> playVfsTrack(String zipFilePath, VfsEntry track) async {
    final title = track.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    final artist = track.path.contains('/') ? track.path.split('/').first : 'Unknown Artist';

    // 1. 잠금화면 / 알림바 메타데이터 갱신
    final item = MediaItem(
      id: track.id,
      title: title,
      artist: artist,
      album: zipFilePath.split('/').last,
      extras: {'vfsPath': track.path},
    );
    mediaItem.add(item);

    // 2. 디스크 풀림 없이 오디오 청크 추출
    final audioBytes = await ZipVfsReader.extractAudioChunk(zipFilePath, track);

    // 3. MIME 타입 판별
    String mime = 'audio/mpeg';
    final format = track.audioFormat?.toLowerCase() ?? 'mp3';
    if (format == 'flac') {
      mime = 'audio/flac';
    } else if (format == 'wav') {
      mime = 'audio/wav';
    } else if (format == 'aac' || format == 'm4a') {
      mime = 'audio/aac';
    } else if (format == 'ogg' || format == 'opus') {
      mime = 'audio/ogg';
    }

    // 4. MemoryAudioSource 설정 및 재생 시작
    final source = MemoryAudioSource(audioBytes, contentType: mime);
    await _player.setAudioSource(source);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setVolume(double volume) => _player.setVolume(volume);
}
