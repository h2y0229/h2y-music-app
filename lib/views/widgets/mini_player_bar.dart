import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/vfs_provider.dart';
import 'glass_container.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final vfs = context.watch<VfsProvider>();
    final player = context.watch<PlayerProvider>();
    final track = player.currentPlayingTrack;

    final title =
        track?.name.replaceAll(RegExp(r'\.[^.]+$'), '') ?? '선택된 트랙 없음';
    final artist = track?.path.contains('/') ?? false
        ? track!.path.split('/').first
        : '대기 중';

    final pos = player.position;
    final dur = player.duration;
    final maxSec = dur.inSeconds > 0 ? dur.inSeconds.toDouble() : 1.0;
    final curSec = pos.inSeconds.clamp(0, dur.inSeconds).toDouble();

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      borderRadius: 20.0,
      backgroundColor: AppColors.glassBase,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 트랙 정보 & 대형 재생 제어 버튼 행
          Row(
            children: [
              // 앨범 아트 썸네일 (54x54)
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorderBright),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.accentCyan, size: 28),
              ),
              const SizedBox(width: 14),

              // 트랙명 & 아티스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      artist,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 이전 곡 (대형화)
              IconButton(
                iconSize: 34,
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                icon: const Icon(Icons.skip_previous_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => player.prevTrack(vfs.filteredTracks),
              ),
              const SizedBox(width: 4),

              // 재생 / 일시정지 버튼 (62px 초대형 네온 원형 버튼)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan
                          .withValues(alpha: player.isPlaying ? 0.6 : 0.35),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: IconButton(
                  iconSize: 38,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF030712),
                  ),
                  onPressed: () => player.togglePlay(),
                ),
              ),
              const SizedBox(width: 4),

              // 다음 곡 (대형화)
              IconButton(
                iconSize: 34,
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                icon: const Icon(Icons.skip_next_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => player.nextTrack(vfs.filteredTracks),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. 프로그레스 타임라인 슬라이더 & 시간 레이블
          Row(
            children: [
              Text(
                _formatDuration(pos),
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
              Expanded(
                child: Slider(
                  value: curSec.clamp(0.0, maxSec),
                  max: maxSec,
                  onChanged: (val) {
                    player.seekTo(Duration(seconds: val.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(dur),
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
