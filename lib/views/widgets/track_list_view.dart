import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vfs_entry.dart';
import '../../providers/player_provider.dart';
import '../../providers/vfs_provider.dart';
import 'glass_container.dart';

class TrackListView extends StatelessWidget {
  const TrackListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vfs = context.watch<VfsProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = vfs.filteredTracks;

    return Column(
      children: [
        // 1. 트랙 검색창
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          borderRadius: 12.0,
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => vfs.setSearchQuery(val),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: '트랙 검색 (제목, 경로)...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. 트랙 리스트 영역
        Expanded(
          child: tracks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      vfs.currentAnalysis == null
                          ? '압축 파일(ZIP)을 불러오면\n여기에 오디오 트랙이 표시됩니다.'
                          : '일치하는 오디오 트랙이 없습니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isPlaying = player.currentPlayingTrack?.id == track.id;

                    return _buildTrackTile(context, track, index + 1, isPlaying, () {
                      vfs.selectTrack(track);
                      if (vfs.currentAnalysis != null) {
                        player.playTrack(vfs.currentAnalysis!.filePath, track);
                      }
                    });
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTrackTile(
    BuildContext context,
    VfsEntry track,
    int index,
    bool isPlaying,
    VoidCallback onTap,
  ) {
    final format = (track.audioFormat ?? 'AUDIO').toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GlassContainer(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        borderRadius: 10.0,
        backgroundColor: isPlaying
            ? AppColors.accentCyanDim.withValues(alpha: 0.25)
            : AppColors.glassCard,
        borderColor: isPlaying
            ? AppColors.accentCyan.withValues(alpha: 0.4)
            : AppColors.glassBorder,
        child: Row(
          children: [
            // 인덱스 또는 재생 애니메이션 아이콘
            SizedBox(
              width: 26,
              child: isPlaying
                  ? const Icon(Icons.equalizer_rounded, color: AppColors.accentCyan, size: 18)
                  : Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
            ),
            const SizedBox(width: 8),

            // 트랙 제목 및 가상 경로
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: TextStyle(
                      color: isPlaying ? AppColors.accentCyan : AppColors.textPrimary,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.path,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 포맷 배지 및 크기
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                format,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              track.formattedSize,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
