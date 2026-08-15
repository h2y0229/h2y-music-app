import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'engine/audio/audio_player_handler.dart';
import 'providers/player_provider.dart';
import 'providers/vfs_provider.dart';
import 'views/app_shell_view.dart';

late final AudioPlayerHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 오버레이 설정 (투명 상태바)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // AudioService 백그라운드 오디오 핸들러 초기화
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.h2y.musicapp.audio',
      androidNotificationChannelName: 'h2y Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
    ),
  );

  runApp(const H2yMusicApp());
}

class H2yMusicApp extends StatelessWidget {
  const H2yMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VfsProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider(audioHandler)),
      ],
      child: MaterialApp(
        title: 'h2y Music Player',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppShellView(),
      ),
    );
  }
}
