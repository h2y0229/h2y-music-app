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
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'VFS Range Read 인덱싱 중...',
              style: TextStyle(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '디스크 무해제 헤더 분석 중',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final hasArchive = vfs.currentAnalysis != null;

    return GlassContainer(
      onTap: () => vfs.pickArchiveFile(),
      borderColor: hasArchive ? AppColors.accentCyan.withValues(alpha: 0.4) : AppColors.glassBorder,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentCyanDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.folder_zip_rounded,
                  color: AppColors.accentCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasArchive ? vfs.currentAnalysis!.fileName : '압축 파일 선택 (ZIP)',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasArchive
                          ? '엔트리 ${vfs.currentAnalysis!.entryCount}개 (${vfs.currentAnalysis!.analysisTimeMs}ms)'
                          : '디스크 해제 없이 즉시 스트리밍 재생',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.file_upload_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('ZIP', AppColors.accentCyan, AppColors.accentCyanDim),
              const SizedBox(width: 6),
              _buildBadge('7Z', AppColors.accentPurple, AppColors.accentPurpleDim),
              const SizedBox(width: 6),
              _buildBadge('RAR', AppColors.accentCyan, AppColors.accentCyanDim),
              const SizedBox(width: 6),
              _buildBadge('TAR', AppColors.accentPurple, AppColors.accentPurpleDim),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
