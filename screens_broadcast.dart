import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'models.dart';
import 'player_service.dart';
import 'widgets.dart';

class BroadcastTab extends StatelessWidget {
  const BroadcastTab({super.key});

  void _addSheet(BuildContext context) {
    final form = GlobalKey<FormState>();
    final name = TextEditingController();
    final url = TextEditingController();
    final desc = TextEditingController();
    final acc = context.read<AccountService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Yeni kanal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Kanal adı'),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Ad gir' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Yayın adresi (http://...)',
                  hintText: 'https://sunucu.com:8000/yayin',
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  return (t.startsWith('http://') || t.startsWith('https://'))
                      ? null
                      : 'http:// veya https:// ile başlamalı';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    final nav = Navigator.of(ctx);
                    await acc.addChannel(name.text, url.text, desc.text);
                    nav.pop();
                  },
                  child: const Text('Kanalı ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountService>();
    final player = context.watch<PlayerService>();
    final mine = acc.myChannels;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Yayıncı Paneli',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Kendi yayınını nasıl yaparsın?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ]),
                SizedBox(height: 10),
                Text(
                  '1) Ücretsiz bir Icecast / Shoutcast / AzuraCast sunucusu kur veya kirala.\n'
                  '2) Bilgisayarında BUTT veya OBS gibi bir yayın programıyla sunucuya bağlan.\n'
                  '3) Sunucunun verdiği dinleme adresini buraya kanal olarak ekle.\n\n'
                  'Kanalın hesabına kaydolur, uygulamadan her yerde dinleyebilirsin.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Kanallarım',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              FilledButton.icon(
                onPressed: () => _addSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Kanal ekle'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (mine.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Henüz kanalın yok.')),
            )
          else
            for (final Station s in mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      StationLogo(station: s),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(s.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(player.current?.id == s.id && player.playing
                            ? Icons.pause_circle
                            : Icons.play_circle),
                        iconSize: 34,
                        onPressed: () => player.play(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => acc.removeChannel(s),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
