class Station {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String tags;
  final int bitrate;
  final bool custom;
  final String description;

  const Station({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.tags = '',
    this.bitrate = 0,
    this.custom = false,
    this.description = '',
  });

  factory Station.fromRadioBrowser(Map<String, dynamic> j) {
    final resolved = (j['url_resolved'] ?? '').toString().trim();
    final raw = (j['url'] ?? '').toString().trim();
    final fav = (j['favicon'] ?? '').toString().trim();
    final br = j['bitrate'];
    return Station(
      id: (j['stationuuid'] ?? '').toString(),
      name: (j['name'] ?? '').toString().trim(),
      url: resolved.isNotEmpty ? resolved : raw,
      logo: fav.isEmpty ? null : fav,
      tags: (j['tags'] ?? '').toString(),
      bitrate: br is int ? br : 0,
    );
  }

  factory Station.fromJson(Map<String, dynamic> j) => Station(
        id: j['id'] as String,
        name: j['name'] as String,
        url: j['url'] as String,
        logo: j['logo'] as String?,
        tags: (j['tags'] ?? '') as String,
        bitrate: (j['bitrate'] ?? 0) as int,
        custom: (j['custom'] ?? false) as bool,
        description: (j['description'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'logo': logo,
        'tags': tags,
        'bitrate': bitrate,
        'custom': custom,
        'description': description,
      };

  String get subtitle {
    if (custom) return description.isEmpty ? 'Benim kanalım' : description;
    final t = tags.split(',').where((e) => e.trim().isNotEmpty).take(2).join(' • ');
    final b = bitrate > 0 ? '$bitrate kbps' : '';
    return [t, b].where((e) => e.isNotEmpty).join('  ·  ');
  }
}

class Account {
  final String email;
  final String name;
  final String salt;
  final String hash;

  const Account({
    required this.email,
    required this.name,
    required this.salt,
    required this.hash,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        email: j['email'] as String,
        name: j['name'] as String,
        salt: j['salt'] as String,
        hash: j['hash'] as String,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'salt': salt,
        'hash': hash,
      };
}
