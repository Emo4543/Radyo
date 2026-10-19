import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'player_service.dart';
import 'widgets.dart';

void openPlayer(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const PlayerScreen(),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(anim),
      child: child,
    ),
  ));
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  void _sleepSheet(BuildContext context, PlayerService p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Uyku zamanlayıcı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            for (final m in [15, 30, 60, 90])
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: Text('$m dakika sonra durdur'),
                onTap: () {
                  p.setSleep(Duration(minutes: m));
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.timer_off_outlined),
              title: const Text('Zamanlayıcıyı kapat'),
              onTap: () {
                p.setSleep(null);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerService>();
    final acc = context.watch<AccountService>();
    final s = p.current;
    if (s == null) {
      return const Scaffold(body: Center(child: Text('Çalan yayın yok')));
    }
    final fav = acc.isFavorite(s);
    final primary = Theme.of(context).colorScheme.primary;
    final status = p.error ?? p.nowPlaying ?? (p.loading ? 'Bağlanıyor…' : 'Canlı yayın');

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('ŞU AN ÇALIYOR',
                            style: TextStyle(letterSpacing: 2, fontSize: 12)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                      color: fav ? Colors.pinkAccent : null,
                      onPressed: () => acc.toggleFavorite(s),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedScale(
                  scale: p.playing ? 1.0 : 0.88,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(p.playing ? 0.45 : 0.15),
                          blurRadius: 50,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: StationLogo(station: s, size: 240, radius: 32),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  s.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    status,
                    key: ValueKey(status),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.error != null ? Colors.redAccent : primary,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                EqualizerBars(active: p.playing, height: 36, color: primary),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await p.stop();
                        nav.pop();
                      },
                    ),
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: FilledButton(
                        style: FilledButton.styleFrom(shape: const CircleBorder()),
                        onPressed: p.toggle,
                        child: p.loading
                            ? const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : Icon(p.playing ? Icons.pause : Icons.play_arrow, size: 46),
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: Icon(p.sleepAt != null ? Icons.bedtime : Icons.bedtime_outlined),
                      onPressed: () => _sleepSheet(context, p),
                    ),
                  ],
                ),
                if (p.sleepAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Uyku: ${p.sleepAt!.hour.toString().padLeft(2, '0')}:${p.sleepAt!.minute.toString().padLeft(2, '0')} saatinde durur',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.volume_mute),
                    Expanded(
                      child: Slider(value: p.volume, onChanged: p.setVolume),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
