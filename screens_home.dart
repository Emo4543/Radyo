import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'screens_broadcast.dart';
import 'station_service.dart';
import 'theme.dart';
import 'widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: IndexedStack(
          index: _i,
          children: const [
            ExploreTab(),
            FavoritesTab(),
            BroadcastTab(),
            ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _i,
            onDestinationSelected: (v) => setState(() => _i = v),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.radio_outlined), selectedIcon: Icon(Icons.radio), label: 'Keşfet'),
              NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoriler'),
              NavigationDestination(icon: Icon(Icons.podcasts_outlined), selectedIcon: Icon(Icons.podcasts), label: 'Yayıncı'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ],
      ),
    );
  }
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<StationService>();
    final acc = context.watch<AccountService>();
    final first = (acc.user?.name ?? '').split(' ').first;
    final list = svc.stations
        .where((s) =>
            _q.isEmpty ||
            s.name.toLowerCase().contains(_q) ||
            s.tags.toLowerCase().contains(_q))
        .toList();

    Widget body;
    if (svc.loading && svc.stations.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (svc.error != null && svc.stations.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(svc.error!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => svc.load(force: true),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    } else if (list.isEmpty) {
      body = const Center(child: Text('Sonuç bulunamadı'));
    } else {
      body = RefreshIndicator(
        onRefresh: () => svc.load(force: true),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: list.length,
          itemBuilder: (_, i) => StationTile(
            key: ValueKey(list[i].id),
            station: list[i],
            index: i,
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                first.isEmpty ? 'Merhaba' : 'Merhaba, $first',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Türkiye\'nin en çok dinlenen radyoları',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'İstasyon veya tür ara…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<AccountService>().favorites;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Favorilerim',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: favs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Henüz favorin yok.\nKeşfet sekmesinde kalbe dokunarak ekle.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: favs.length,
                    itemBuilder: (_, i) => StationTile(
                      key: ValueKey('f_${favs[i].id}'),
                      station: favs[i],
                      index: i,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountService>();
    final theme = context.watch<ThemeController>();
    final u = acc.user;
    if (u == null) return const SizedBox.shrink();
    final initial = u.name.isEmpty ? '?' : u.name.characters.first.toUpperCase();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profil',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: kViolet,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(u.email),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Stat(label: 'Favori', value: '${acc.favorites.length}')),
              const SizedBox(width: 12),
              Expanded(child: _Stat(label: 'Kanalım', value: '${acc.myChannels.length}')),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Görünüm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('Sistem'), icon: Icon(Icons.phone_android)),
                      ButtonSegment(value: ThemeMode.light, label: Text('Açık'), icon: Icon(Icons.light_mode)),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Koyu'), icon: Icon(Icons.dark_mode)),
                    ],
                    selected: {theme.mode},
                    onSelectionChanged: (s) => theme.set(s.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış yap'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Çıkış yapılsın mı?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Çıkış yap')),
                  ],
                ),
              );
              if (ok == true) await acc.logout();
            },
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary)),
          Text(label),
        ],
      ),
    );
  }
}
