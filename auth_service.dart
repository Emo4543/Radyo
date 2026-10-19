import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Hesap, favoriler ve kullanıcı kanalları.
/// Veriler cihazda tutulur; şifreler tuzlanmış ve çok turlu SHA-256 ile saklanır.
/// Firebase'e geçmek istersen sadece bu dosyayı değiştirmen yeterli.
class AccountService extends ChangeNotifier {
  SharedPreferences? _p;
  Account? _user;
  bool ready = false;
  List<Station> _favs = [];
  List<Station> _mine = [];

  Account? get user => _user;
  List<Station> get favorites => List.unmodifiable(_favs);
  List<Station> get myChannels => List.unmodifiable(_mine);

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    final key = _p!.getString('session');
    if (key != null) {
      _user = _users()[key];
      _loadData();
    }
    ready = true;
    notifyListeners();
  }

  Map<String, Account> _users() {
    final raw = _p!.getString('users');
    if (raw == null) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, Account.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _saveUsers(Map<String, Account> u) async {
    await _p!.setString('users', jsonEncode(u.map((k, v) => MapEntry(k, v.toJson()))));
  }

  String _hash(String pass, String salt) {
    List<int> d = utf8.encode('$salt:$pass');
    for (var i = 0; i < 6000; i++) {
      d = sha256.convert(d).bytes;
    }
    return base64.encode(d);
  }

  String _newSalt() {
    final r = Random.secure();
    return base64.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  Future<String?> register(String name, String email, String pass) async {
    final key = email.trim().toLowerCase();
    final users = _users();
    if (users.containsKey(key)) return 'Bu e-posta ile zaten bir hesap var.';
    final salt = _newSalt();
    users[key] = Account(
      email: key,
      name: name.trim(),
      salt: salt,
      hash: _hash(pass, salt),
    );
    await _saveUsers(users);
    await _p!.setString('session', key);
    _user = users[key];
    _loadData();
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String pass) async {
    final key = email.trim().toLowerCase();
    final acc = _users()[key];
    if (acc == null || acc.hash != _hash(pass, acc.salt)) {
      return 'E-posta veya şifre hatalı.';
    }
    await _p!.setString('session', key);
    _user = acc;
    _loadData();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _p!.remove('session');
    _user = null;
    _favs = [];
    _mine = [];
    notifyListeners();
  }

  List<Station> _readList(String key) {
    final raw = _p!.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _loadData() {
    final k = _user!.email;
    _favs = _readList('fav_$k');
    _mine = _readList('mine_$k');
  }

  Future<void> _save() async {
    final k = _user!.email;
    await _p!.setString('fav_$k', jsonEncode(_favs.map((e) => e.toJson()).toList()));
    await _p!.setString('mine_$k', jsonEncode(_mine.map((e) => e.toJson()).toList()));
  }

  bool isFavorite(Station s) => _favs.any((e) => e.id == s.id);

  Future<void> toggleFavorite(Station s) async {
    if (_user == null) return;
    if (isFavorite(s)) {
      _favs.removeWhere((e) => e.id == s.id);
    } else {
      _favs.add(s);
    }
    notifyListeners();
    await _save();
  }

  Future<void> addChannel(String name, String url, String description) async {
    if (_user == null) return;
    _mine.add(Station(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      url: url.trim(),
      custom: true,
      description: description.trim(),
    ));
    notifyListeners();
    await _save();
  }

  Future<void> removeChannel(Station s) async {
    _mine.removeWhere((e) => e.id == s.id);
    _favs.removeWhere((e) => e.id == s.id);
    notifyListeners();
    await _save();
  }
}
