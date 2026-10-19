import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'player_service.dart';
import 'screens_auth.dart';
import 'screens_home.dart';
import 'station_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.zenith.radyo.audio',
    androidNotificationChannelName: 'Radyo çalma',
    androidNotificationOngoing: true,
  );
  final theme = ThemeController();
  await theme.load();
  final account = AccountService();
  await account.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: theme),
      ChangeNotifierProvider.value(value: account),
      ChangeNotifierProvider(create: (_) => StationService()..load()),
      ChangeNotifierProvider(create: (_) => PlayerService()),
    ],
    child: const RadyoApp(),
  ));
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
      home: const _Gate(),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountService>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: acc.user == null
          ? const AuthScreen(key: ValueKey('auth'))
          : const HomeShell(key: ValueKey('home')),
    );
  }
}
