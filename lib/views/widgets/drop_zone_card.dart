import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/vfs_provider.dart';
import 'glass_container.dart';

class DropZoneCard extends StatelessWidget {
  const DropZoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vfs = context.watch<VfsProvider>();

    if (vfs.isLoading) {
      return const GlassContainer(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        borderRadius: 12.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'VFS Range Read 헤더 분석 중...',
              style: TextStyle(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final hasArchive = vfs.currentAnalysis != null;

    return GlassContainer(
      onTap: () => vfs.pickArchiveFile(),
      borderColor: hasArchive ? AppColors.accentCyan.withValues(alpha: 0.4) : AppColors.glassBorder,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      borderRadius: 12.0,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentCyanDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.folder_zip_rounded,
              color: AppColors.accentCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasArchive ? vfs.currentAnalysis!.fileName : '압축 파일 선택 (ZIP / 7Z / RAR)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hasArchive
                      ? '트랙 ${vfs.currentAnalysis!.entryCount}개 (${vfs.currentAnalysis!.analysisTimeMs}ms) • 변경하려면 터치'
                      : '디스크 무해제 온디맨드 스트리밍',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasArchive ? AppColors.accentCyanDim : AppColors.bgSurface3,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.glassBorderBright),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasArchive ? Icons.swap_horiz_rounded : Icons.file_upload_outlined,
                  color: hasArchive ? AppColors.accentCyan : AppColors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  hasArchive ? '변경' : '열기',
                  style: TextStyle(
                    color: hasArchive ? AppColors.accentCyan : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
