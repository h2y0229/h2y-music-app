import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

/// 메모리 상의 오디오 바이트(`Uint8List`)를 `just_audio` 재생 파이프라인으로 직접 스트리밍하는 소스
class MemoryAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  final String _contentType;

  MemoryAudioSource(this._bytes, {String contentType = 'audio/mpeg'})
      : _contentType = contentType;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;

    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: _contentType,
    );
  }
}
