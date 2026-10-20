import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://ictoizlfrkewcgrqgydi.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_o2mtSdF5IYQwAIIy_lc-NA_f_EYgu91'),
  );

  runApp(const ZenithRadyoApp());
}

final supabase = Supabase.instance.client;

class ZenithRadyoApp extends StatelessWidget {
  const ZenithRadyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenith Radyo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        primaryColor: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: supabase.auth.currentSession == null 
          ? const AuthScreen() 
          : const MainHomeScreen(),
    );
  }
}

// ==========================================
// 1. GİRİŞ VE KAYIT EKRANI
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kullanıcı adı ve şifre girin!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = '$username@zenithradyo.app';

      if (_isSignUp) {
        await supabase.auth.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarılı! Giriş yapılıyor...')),
          );
        }
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: const Color(0xFF181828),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radio, size: 70, color: Colors.deepPurpleAccent),
              const SizedBox(height: 12),
              const Text(
                'ZENITH RADYO',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isSignUp ? 'Kayıt Ol' : 'Giriş Yap', style: const TextStyle(fontSize: 16)),
                    ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'Zaten hesabın var mı? Giriş Yap' : 'Hesabın yok mu? Kayıt Ol'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ANA EKRAN
// ==========================================
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RadioPlayerTab(),
    const GlobalChatTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zenith Radyo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF141424),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF141424),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radyolar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Global Sohbet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ==========================================
// 3. RADYOLAR VE CANLI CANLI ÇALAR (Eski Tam Liste)
// ==========================================
class RadioPlayerTab extends StatefulWidget {
  const RadioPlayerTab({super.key});

  @override
  State<RadioPlayerTab> createState() => _RadioPlayerTabState();
}

class _RadioPlayerTabState extends State<RadioPlayerTab> {
  late AudioPlayer _audioPlayer;
  String? _currentPlayingUrl;
  String _currentStationName = 'Bir radyo seçin';
  bool _isPlaying = false;
  bool _isLoading = false;

  // Türkçe ve Popüler Radyo Listesi
  final List<Map<String, String>> _radios = [
    {'name': 'Kral FM', 'url': 'https://kralfm.radyotvonline.net/kralfm.stream'},
    {'name': 'Kral Pop', 'url': 'https://kralpop.radyotvonline.net/kralpop.stream'},
    {'name': 'Power FM', 'url': 'https://powerfm.listenpowerapp.com/powerfm/mpeg/icecast.audio'},
    {'name': 'Power Türk', 'url': 'https://powerturk.listenpowerapp.com/powerturk/mpeg/icecast.audio'},
    {'name': 'Alem FM', 'url': 'http://sct.akamaized.net/alemfm/alemfm.stream/playlist.m3u8'},
    {'name': 'Süper FM', 'url': 'https://stream.carnival.com.tr/superfm.aac'},
    {'name': 'Joy FM', 'url': 'https://stream.carnival.com.tr/joyfm.aac'},
    {'name': 'Joy Türk', 'url': 'https://stream.carnival.com.tr/joyturk.aac'},
    {'name': 'Radyo D', 'url': 'https://demiroren.livebox.services/radyod.stream/playlist.m3u8'},
    {'name': 'Metro FM', 'url': 'https://stream.carnival.com.tr/metrofm.aac'},
    {'name': 'Radyo Fenomen', 'url': 'https://fenomen.listenpowerapp.com/fenomen/mpeg/icecast.audio'},
    {'name': 'Virgin Radio TR', 'url': 'https://stream.carnival.com.tr/virginradio.aac'},
    {'name': 'TRT FM', 'url': 'https://rb-trtfm.medya.trt.com.tr/master.m3u8'},
    {'name': 'Kafa Radyo', 'url': 'https://stream.kafaradyo.com/kafaradyo.aac'},
    {'name': 'Number 1 FM', 'url': 'https://n10101.com/nr1fm'},
    {'name': 'Number 1 Türk', 'url': 'https://n10101.com/nr1turk'},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  Future<void> _playRadio(String name, String url) async {
    try {
      if (_currentPlayingUrl == url && _isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      setState(() {
        _currentStationName = name;
        _currentPlayingUrl = url;
        _isLoading = true;
      });

      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yayın açılırken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Şu An Çalan Barı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C2E),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.radio_outlined, color: Colors.deepPurpleAccent, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStationName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlaying ? '• Canlı Yayın Yapılıyor' : '• Durduruldu',
                      style: TextStyle(
                        color: _isPlaying ? Colors.greenAccent : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_currentPlayingUrl != null)
                IconButton(
                  iconSize: 42,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  color: Colors.deepPurpleAccent,
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Radyo Listesi
        Expanded(
          child: ListView.builder(
            itemCount: _radios.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemBuilder: (context, index) {
              final radio = _radios[index];
              final isSelected = _currentPlayingUrl == radio['url'];

              return Card(
                color: isSelected ? const Color(0xFF2A2A48) : const Color(0xFF181826),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.white12,
                    child: Icon(
                      isSelected && _isPlaying ? Icons.volume_up : Icons.radio,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  title: Text(
                    radio['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    isSelected && _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.grey,
                  ),
                  onTap: () => _playRadio(radio['name']!, radio['url']!),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. CANLI GLOBAL SOHBET
// ==========================================
class GlobalChatTab extends StatefulWidget {
  const GlobalChatTab({super.key});

  @override
  State<GlobalChatTab> createState() => _GlobalChatTabState();
}

class _GlobalChatTabState extends State<GlobalChatTab> {
  final _msgController = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    _msgController.clear();

    await supabase.from('messages').insert({
      'user_id': user.id,
      'content': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('messages')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!;

              if (messages.isEmpty) {
                return const Center(child: Text('Henüz mesaj yok. İlk mesajı sen yaz!'));
              }

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['user_id'] == supabase.auth.currentUser?.id;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.deepPurpleAccent : const Color(0xFF242438),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAlignment.end : CrossAlignment.start,
                        children: [
                          Text(
                            msg['content'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF141424),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 5. PROFİL SEKMESİ
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final username = user?.email?.split('@').first ?? 'Kullanıcı';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurpleAccent,
            child: Icon(Icons.person, size: 55, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Colors.greenAccent, size: 12),
              SizedBox(width: 6),
              Text('Çevrimiçi', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
