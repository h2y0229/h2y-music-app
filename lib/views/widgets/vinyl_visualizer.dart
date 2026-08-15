import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/vfs_provider.dart';
import 'glass_container.dart';

class VinylVisualizer extends StatefulWidget {
  const VinylVisualizer({super.key});

  @override
  State<VinylVisualizer> createState() => _VinylVisualizerState();
}

class _VinylVisualizerState extends State<VinylVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vfs = context.watch<VfsProvider>();
    final player = context.watch<PlayerProvider>();
    final track = player.currentPlayingTrack ?? vfs.selectedTrack;

    if (player.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
    } else {
      if (_rotationController.isAnimating) _rotationController.stop();
    }

    if (track == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassCard,
                border: Border.all(color: AppColors.glassBorderBright),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: AppColors.textMuted,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '선택된 트랙이 없습니다',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ZIP 압축 파일을 열고 오디오 트랙을 선택해 주세요',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final title = track.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    final format = (track.audioFormat ?? 'AUDIO').toUpperCase();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // 1. 회전 바이닐 디스크
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: child,
              );
            },
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF222436),
                    Color(0xFF0C0D15),
                    Color(0xFF1B1D2C),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Color(0xFF030712),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. 트랙 제목 및 메타데이터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.path,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // 메타데이터 배지
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMetaBadge(format, AppColors.accentCyan),
                    const SizedBox(width: 6),
                    _buildMetaBadge(
                      'Offset 0x${track.localHeaderOffset.toRadixString(16).toUpperCase()}',
                      AppColors.accentPurple,
                    ),
                    const SizedBox(width: 6),
                    _buildMetaBadge(track.formattedSize, AppColors.accentEmerald),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. 오디오 스펙트럼 비주얼라이저 시뮬레이션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              borderRadius: 14.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (index) {
                  final height = (sin(index * 0.5 + (player.isPlaying ? _rotationController.value * 10 : 0)) * 14 + 18).clamp(6.0, 36.0);
                  return Container(
                    width: 4,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetaBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
