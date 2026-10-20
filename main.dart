import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'player_service.dart';
import 'screens_auth.dart';
import 'screens_home.dart';
import 'station_service.dart';
import 'theme.dart';

String? startupNote;

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (details) => Material(
          color: const Color(0xFF0A0E1A),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                'Hata: ${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ),
        );

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await JustAudioBackground.init(
          androidNotificationChannelId: 'com.zenith.radyo.audio',
          androidNotificationChannelName: 'Radyo çalma',
          androidNotificationOngoing: true,
        );
      } catch (e) {
        startupNote = 'Arka plan ses servisi başlatılamadı: $e';
      }
    }

    final theme = ThemeController();
    final account = AccountService();
    try {
      await theme.load();
      await account.init();
    } catch (e) {
      startupNote = '${startupNote ?? ''}\nVeri yüklenemedi: $e';
    }

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: account),
        ChangeNotifierProvider(create: (_) => StationService()..load()),
        ChangeNotifierProvider(create: (_) => PlayerService()),
      ],
      child: const RadyoApp(),
    ));
  }, (error, stack) {
    startupNote = '${startupNote ?? ''}\n$error';
  });
}

class RadyoApp extends StatelessWidget {
  const RadyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<ThemeController>();
    return MaterialApp(
      title: 'Zenith Radyo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: tc.mode,
      builder: (context, child) => Container(
        color: const Color(0xFF0A0E1A),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
      home: const _Gate(),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountService>();
    final page = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: acc.user == null
          ? const AuthScreen(key: ValueKey('auth'))
          : const HomeShell(key: ValueKey('home')),
    );
    if (startupNote == null) return page;
    return Column(
      children: [
        Material(
          color: const Color(0xFF5A1010),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                startupNote!.trim(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
        Expanded(child: page),
      ],
    );
  }
}
