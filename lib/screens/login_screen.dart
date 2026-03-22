import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/network_checker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _loading     = false;
  bool _showSenha   = false;
  bool _canBio      = false;

  static const _teal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _emailCtrl.text = await AuthService.getSavedEmail();
    final bio = await AuthService.canUseBiometric();
    if (mounted) setState(() => _canBio = bio);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  // ── Login with email/password ─────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();
    if (email.isEmpty || senha.isEmpty) {
      _snack('Preencha e-mail e senha');
      return;
    }

    if (!await NetworkChecker.isOnline()) {
      _snack('Sem conexão com a internet', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await AuthService.login(email, senha);
      if (data == null) {
        _snack('E-mail ou senha incorretos', error: true);
        return;
      }
      _goHome(data['token']!, data['userId']!);
    } catch (_) {
      _snack('Erro de conexão. Tente novamente.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Login with biometric ──────────────────────────────────────────────────
  Future<void> _loginBio() async {
    setState(() => _loading = true);
    try {
      final data = await AuthService.loginWithBiometric();
      if (data == null) {
        _snack('Biometria falhou. Use e-mail e senha.', error: true);
        return;
      }
      _goHome(data['token']!, data['userId']!);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome(String token, String userId) {
    Navigator.pushReplacementNamed(
      context, '/home',
      arguments: {'token': token, 'usuarioId': userId},
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.redAccent : _teal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Logo ───────────────────────────────────────────────────────
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),

              Text('Bem-vindo!',
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF1A2E35))),
              const SizedBox(height: 6),
              Text('Acesse seus projetos financeiros',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 36),

              // ── Form card ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    _Field(
                      controller: _emailCtrl,
                      hint: 'E-mail',
                      icon: Icons.person_outline_rounded,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _senhaCtrl,
                      hint: 'Senha',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_showSenha,
                      suffix: IconButton(
                        icon: Icon(_showSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20, color: Colors.grey),
                        onPressed: () => setState(() => _showSenha = !_showSenha),
                      ),
                      onSubmit: (_) => _login(),
                    ),
                    const SizedBox(height: 8),

                    // Esqueci minha senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/esqueci-senha'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Esqueci minha senha',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Botão login
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator(color: _teal))
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _teal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text('Entrar',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                    ),

                    // Biometric button
                    if (_canBio) ...[
                      const SizedBox(height: 14),
                      const _Divider(),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _loginBio,
                          icon: const Icon(Icons.fingerprint_rounded, size: 22, color: _teal),
                          label: Text('Entrar com Digital',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _teal)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _teal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                child: Text('Criar nova conta',
                  style: GoogleFonts.poppins(color: _teal, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.obscure  = false,
    this.suffix,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  controller,
      obscureText: obscure,
      keyboardType: keyboard,
      onSubmitted: onSubmit,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF4F6F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Divider(color: Colors.grey.shade200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('ou', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ]);
}