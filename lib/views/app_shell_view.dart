import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'widgets/drop_zone_card.dart';
import 'widgets/glass_container.dart';
import 'widgets/mini_player_bar.dart';
import 'widgets/track_list_view.dart';
import 'widgets/vinyl_visualizer.dart';

class AppShellView extends StatefulWidget {
  const AppShellView({super.key});

  @override
  State<AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends State<AppShellView> {
  int _selectedMobileTab = 0; // 0: Now Playing, 1: Track List

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // 1. 앰비언트 네온 배경 오브
          Positioned(
            top: -100,
            left: -50,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentCyan.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            width: 350,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPurple.withValues(alpha: 0.08),
              ),
            ),
          ),

          // 2. 메인 컨텐츠 영역 (SafeArea)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;

                return Column(
                  children: [
                    // 글로벌 헤더
                    _buildHeader(isWide),

                    // 본문 (태블릿/데스크톱 2단 또는 모바일 탭)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: isWide ? _buildWideLayout() : _buildMobileLayout(),
                      ),
                    ),

                    // 하단 플로팅 플레이어 바
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: MiniPlayerBar(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        borderRadius: 14.0,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on_rounded, color: Color(0xFF030712), size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'h2y Music Player',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'ZIP 무해제 온디맨드 스트리밍 플레이어',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentCyanDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, color: AppColors.accentCyan, size: 8),
                  SizedBox(width: 4),
                  Text(
                    'VFS Ready',
                    style: TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 태블릿 / 데스크톱 가로형 2단 레이아웃
  Widget _buildWideLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 좌측 사이드바: 드롭존 및 트랙 리스트
        SizedBox(
          width: 340,
          child: Column(
            children: [
              DropZoneCard(),
              SizedBox(height: 12),
              Expanded(child: TrackListView()),
            ],
          ),
        ),
        SizedBox(width: 16),

        // 우측 메인 영역: 바이닐 및 비주얼라이저
        Expanded(
          child: GlassContainer(
            borderRadius: 20.0,
            child: VinylVisualizer(),
          ),
        ),
      ],
    );
  }

  /// 모바일 세로형 탭 전환 레이아웃
  Widget _buildMobileLayout() {
    return Column(
      children: [
        const DropZoneCard(),
        const SizedBox(height: 10),

        // 모바일 서브 네비게이션 (Now Playing / Track List)
        Row(
          children: [
            Expanded(
              child: _buildTabButton('Now Playing', 0, Icons.disc_full_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTabButton('Track List', 1, Icons.queue_music_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 선택된 탭 뷰
        Expanded(
          child: _selectedMobileTab == 0
              ? const GlassContainer(
                  borderRadius: 20.0,
                  child: VinylVisualizer(),
                )
              : const TrackListView(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedMobileTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedMobileTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentCyanDim : AppColors.glassCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan.withValues(alpha: 0.5) : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
