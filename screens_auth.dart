import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'theme.dart';
import 'widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _login = true;
  bool _busy = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final acc = context.read<AccountService>();
    final err = _login
        ? await acc.login(_email.text, _pass.text)
        : await acc.register(_name.text, _email.text, _pass.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [kViolet, kAccent]),
                      ),
                      child: const Icon(Icons.bolt, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('ZENITH RADYO',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text(
                      _login ? 'Tekrar hoş geldin' : 'Hesabını oluştur',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              child: _login
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: TextFormField(
                                        controller: _name,
                                        textCapitalization: TextCapitalization.words,
                                        decoration: const InputDecoration(
                                          labelText: 'Ad Soyad',
                                          prefixIcon: Icon(Icons.person_outline),
                                        ),
                                        validator: (v) => (v == null || v.trim().length < 2)
                                            ? 'Adını gir'
                                            : null,
                                      ),
                                    ),
                            ),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-posta',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                return (t.contains('@') && t.contains('.'))
                                    ? null
                                    : 'Geçerli bir e-posta gir';
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass,
                              obscureText: _hide,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _hide = !_hide),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'En az 6 karakter'
                                  : null,
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(_error!,
                                    style: const TextStyle(color: Colors.redAccent)),
                              ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                onPressed: _busy ? null : _submit,
                                child: _busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : Text(_login ? 'Giriş yap' : 'Kayıt ol'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() {
                        _login = !_login;
                        _error = null;
                      }),
                      child: Text(_login
                          ? 'Hesabın yok mu? Kayıt ol'
                          : 'Zaten hesabın var mı? Giriş yap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
