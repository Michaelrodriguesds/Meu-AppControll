import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/network_checker.dart';

class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({super.key});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading    = false;

  static const _teal   = Color(0xFF00897B);
  static const _tealDk = Color(0xFF00695C);
  static const _base   = 'https://backendapp-0bcg.onrender.com/api';

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Informe um e-mail válido', error: true);
      return;
    }

    if (!await NetworkChecker.isOnline()) {
      _snack('Sem conexão com a internet', error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await http.post(
        Uri.parse('$_base/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        // Navega para tela de código — mesmo se e-mail não existir (segurança)
        Navigator.pushNamed(
          context,
          '/verificar-codigo',
          arguments: {'email': email},
        );
      } else if (res.statusCode == 503) {
        _snack('Servidor de e-mail indisponível. Tente novamente.', error: true);
      } else {
        _snack('Erro inesperado. Tente novamente.', error: true);
      }
    } catch (_) {
      if (mounted) _snack('Erro de conexão. Tente novamente.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão voltar
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF455A64)),
                ),
              ),
              const SizedBox(height: 32),

              // Ícone
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_teal, _tealDk],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                      color: _teal.withValues(alpha: 0.35), blurRadius: 16)],
                ),
                child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),

              Text('Esqueci minha senha',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1A2E35))),
              const SizedBox(height: 8),
              Text(
                'Informe seu e-mail e enviaremos um código de 6 dígitos para redefinir sua senha.',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 36),

              // Campo e-mail
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), blurRadius: 16)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('E-MAIL',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                            letterSpacing: .5)),
                    const SizedBox(height: 8),
                    TextField(
                      controller:  _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofocus:   true,
                      style: const TextStyle(fontSize: 14),
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText:  'seu@email.com',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.email_outlined, size: 20, color: Colors.grey.shade400),
                        filled:    true,
                        fillColor: const Color(0xFFF4F6F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _teal, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botão enviar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: _teal))
                    : ElevatedButton.icon(
                        onPressed: _enviar,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: Text('Enviar código',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Dica
              Center(
                child: Text(
                  'Verifique também a pasta de spam.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}