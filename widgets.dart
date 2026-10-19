import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'models.dart';
import 'player_service.dart';
import 'screens_player.dart';
import 'theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF0A0E1A), Color(0xFF151040), Color(0xFF0A0E1A)]
              : const [Color(0xFFF4F7FF), Color(0xFFE9E4FF), Color(0xFFF4F7FF)],
        ),
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: child,
    );
  }
}

class EqualizerBars extends StatefulWidget {
  final bool active;
  final Color color;
  final double height;
  const EqualizerBars({
    super.key,
    required this.active,
    this.color = kAccent,
    this.height = 24,
  });

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) {
              final v = widget.active
                  ? 0.25 + 0.75 * (0.5 + 0.5 * math.sin(_c.value * 2 * math.pi * (i % 3 + 1) + i))
                  : 0.2;
              return Container(
                width: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: widget.height * v,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class StationLogo extends StatelessWidget {
  final Station station;
  final double size;
  final double radius;
  const StationLogo({
    super.key,
    required this.station,
    this.size = 52,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kViolet, kAccent]),
      ),
      child: Icon(Icons.radio, color: Colors.white, size: size * 0.5),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: station.logo == null
          ? fallback
          : Container(
              width: size,
              height: size,
              color: Colors.white,
              child: Image.network(
                station.logo!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback,
              ),
            ),
    );
  }
}

class StationTile extends StatelessWidget {
  final Station station;
  final int index;
  const StationTile({super.key, required this.station, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final acc = context.watch<AccountService>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isCur = player.current?.id == station.id;
    final fav = acc.isFavorite(station);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + math.min(index, 10) * 40),
      tween: Tween(begin: 0, end: 1),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => player.play(station),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: dark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                border: Border.all(
                  color: isCur
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  StationLogo(station: station),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          station.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCur)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: EqualizerBars(
                        active: player.playing,
                        color: Theme.of(context).colorScheme.primary,
                        height: 20,
                      ),
                    ),
                  IconButton(
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                    color: fav ? Colors.pinkAccent : null,
                    onPressed: () => acc.toggleFavorite(station),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerService>();
    final s = p.current;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: s == null
          ? const SizedBox(width: double.infinity)
          : GestureDetector(
              onTap: () => openPlayer(context),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    kViolet.withOpacity(0.9),
                    const Color(0xFF0097B2).withOpacity(0.9),
                  ]),
                ),
                child: Row(
                  children: [
                    StationLogo(station: s, size: 44, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            p.error ?? p.nowPlaying ?? (p.loading ? 'Bağlanıyor…' : 'Canlı yayın'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    EqualizerBars(active: p.playing, color: Colors.white, height: 20),
                    const SizedBox(width: 4),
                    p.loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            ),
                          )
                        : IconButton(
                            color: Colors.white,
                            icon: Icon(p.playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
                            iconSize: 38,
                            onPressed: p.toggle,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
