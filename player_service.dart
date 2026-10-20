import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'models.dart';

class PlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Station? current;
  bool playing = false;
  bool loading = false;
  String? error;
  String? nowPlaying;
  double volume = 1.0;
  DateTime? sleepAt;
  Timer? _sleep;

  PlayerService() {
    _player.playerStateStream.listen((s) {
      playing = s.playing;
      loading = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      notifyListeners();
    });
    _player.icyMetadataStream.listen((m) {
      final t = m?.info?.title?.trim();
      if (t != null && t.isNotEmpty && t != nowPlaying) {
        nowPlaying = t;
        notifyListeners();
      }
    }, onError: (Object e) {});
    _player.playbackEventStream.listen((_) {}, onError: (Object e, StackTrace st) {
      error = 'Yayın açılamadı. Başka bir istasyon dene.';
      loading = false;
      playing = false;
      notifyListeners();
    });
  }

  Future<void> play(Station s) async {
    if (current?.id == s.id && error == null) {
      await toggle();
      return;
    }
    current = s;
    error = null;
    nowPlaying = null;
    loading = true;
    notifyListeners();
    try {
      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(s.url),
        tag: MediaItem(
          id: s.id,
          title: s.name,
          artist: 'Canlı yayın',
          artUri: s.logo != null ? Uri.tryParse(s.logo!) : null,
        ),
      ));
      await _player.setVolume(volume);
      unawaited(_player.play());
    } catch (e) {
      error = 'Yayın açılamadı. Başka bir istasyon dene.';
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (error != null) {
      final s = current!;
      current = null;
      await play(s);
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      unawaited(_player.play());
    }
  }

  Future<void> stop() async {
    await _player.stop();
    current = null;
    nowPlaying = null;
    error = null;
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    volume = v;
    await _player.setVolume(v);
    notifyListeners();
  }

  void setSleep(Duration? d) {
    _sleep?.cancel();
    if (d == null) {
      sleepAt = null;
    } else {
      sleepAt = DateTime.now().add(d);
      _sleep = Timer(d, () async {
        await _player.pause();
        sleepAt = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sleep?.cancel();
    _player.dispose();
    super.dispose();
  }
}
