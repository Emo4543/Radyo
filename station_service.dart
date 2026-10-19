import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Türkiye istasyonlarını radio-browser.info topluluk veritabanından çeker
/// (dinlenme sayısına göre sıralı). Son başarılı liste çevrimdışı için saklanır.
class StationService extends ChangeNotifier {
  static const _hosts = [
    'de1.api.radio-browser.info',
    'nl1.api.radio-browser.info',
    'at1.api.radio-browser.info',
  ];

  List<Station> stations = [];
  bool loading = false;
  String? error;

  Future<void> load({bool force = false}) async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();

    final p = await SharedPreferences.getInstance();
    if (stations.isEmpty) {
      final c = p.getString('cache_stations');
      if (c != null) {
        try {
          stations = (jsonDecode(c) as List)
              .map((e) => Station.fromJson(e as Map<String, dynamic>))
              .toList();
          notifyListeners();
        } catch (_) {}
      }
    }

    for (final host in _hosts) {
      try {
        final uri = Uri.https(host, '/json/stations/bycountrycodeexact/TR', {
          'order': 'clickcount',
          'reverse': 'true',
          'hidebroken': 'true',
          'limit': '200',
        });
        final r = await http
            .get(uri, headers: {'User-Agent': 'ZenithRadyo/1.0'})
            .timeout(const Duration(seconds: 12));
        if (r.statusCode != 200) continue;
        final seen = <String>{};
        final list = <Station>[];
        for (final e in jsonDecode(r.body) as List) {
          final s = Station.fromRadioBrowser(e as Map<String, dynamic>);
          if (s.name.isEmpty || !s.url.startsWith('http')) continue;
          if (!seen.add(s.name.toLowerCase())) continue;
          list.add(s);
          if (list.length >= 120) break;
        }
        if (list.isNotEmpty) {
          stations = list;
          await p.setString(
              'cache_stations', jsonEncode(list.map((e) => e.toJson()).toList()));
          loading = false;
          error = null;
          notifyListeners();
          return;
        }
      } catch (_) {}
    }

    loading = false;
    if (stations.isEmpty) {
      error = 'İstasyonlar yüklenemedi. İnternet bağlantını kontrol et.';
    }
    notifyListeners();
  }
}
