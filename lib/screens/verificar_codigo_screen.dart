import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class VerificarCodigoScreen extends StatefulWidget {
  final String email;
  const VerificarCodigoScreen({super.key, required this.email});

  @override
  State<VerificarCodigoScreen> createState() => _VerificarCodigoScreenState();
}

class _VerificarCodigoScreenState extends State<VerificarCodigoScreen> {
  // 6 campos individuais para o código
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focuses = List.generate(6, (_) => FocusNode());

  final _senhaCtrl    = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _showSenha    = false;
  bool _showConfirma = false;
  bool _codigoValido = false;   // passa para etapa 2 após verificar
  bool _loading      = false;

  static const _teal   = Color(0xFF00897B);
  static const _tealDk = Color(0xFF00695C);
  static const _base   = 'https://backendapp-0bcg.onrender.com/api';

  @override
  void dispose() {
    for (final c in _ctrls)   { c.dispose(); }
    for (final f in _focuses) { f.dispose(); }
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  String get _codigoCompleto => _ctrls.map((c) => c.text).join();

  // ── Verifica código (etapa 1) ─────────────────────────────────────────────
  Future<void> _verificarCodigo() async {
    if (_codigoCompleto.length < 6) {
      _snack('Digite todos os 6 dígitos', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'code': _codigoCompleto}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => _codigoValido = true);
      } else {
        final detail = jsonDecode(res.body)['detail'] ?? 'Código inválido.';
        _snack(detail, error: true);
      }
    } catch (_) {
      if (mounted) _snack('Erro de conexão.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Redefine senha (etapa 2) ──────────────────────────────────────────────
  Future<void> _redefinirSenha() async {
    final senha    = _senhaCtrl.text;
    final confirma = _confirmaCtrl.text;

    if (senha.length < 6) {
      _snack('A senha deve ter no mínimo 6 caracteres', error: true);
      return;
    }
    if (senha != confirma) {
      _snack('As senhas não coincidem', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':        widget.email,
          'code':         _codigoCompleto,
          'new_password': senha,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _showSucesso();
      } else {
        final detail = jsonDecode(res.body)['detail'] ?? 'Erro ao redefinir senha.';
        _snack(detail, error: true);
      }
    } catch (_) {
      if (mounted) _snack('Erro de conexão.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.check_circle_rounded, color: _teal, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Senha redefinida!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Sua senha foi alterada com sucesso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Fazer login',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.redAccent : _teal,
    ));
  }

  // ── Lida com digitação no código ─────────────────────────────────────────
  void _onCodeInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focuses[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focuses[index - 1].requestFocus();
    }
    setState(() {});
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
              // Voltar
              GestureDetector(
                onTap: () => _codigoValido
                    ? setState(() => _codigoValido = false)
                    : Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: Color(0xFF455A64)),
                ),
              ),
              const SizedBox(height: 32),

              // Ícone + título
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_teal, _tealDk],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.35), blurRadius: 16)],
                ),
                child: Icon(
                  _codigoValido ? Icons.lock_open_rounded : Icons.mark_email_read_rounded,
                  color: Colors.white, size: 32,
                ),
              ),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _codigoValido ? _tituloPasso2() : _tituloPasso1(),
              ),
              const SizedBox(height: 32),

              // Etapa 1 — digitar código / Etapa 2 — nova senha
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _codigoValido ? _formNovaSenha() : _formCodigo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloPasso1() => Column(
        key: const ValueKey('t1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verifique seu e-mail',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A2E35))),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              children: [
                const TextSpan(text: 'Enviamos um código de 6 dígitos para '),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Color(0xFF00897B)),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _tituloPasso2() => Column(
        key: const ValueKey('t2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nova senha',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A2E35))),
          const SizedBox(height: 6),
          Text('Código verificado! Agora defina sua nova senha.',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
        ],
      );

  // ── Form etapa 1: dígitos do código ───────────────────────────────────────
  Widget _formCodigo() => Column(
        key: const ValueKey('f1'),
        children: [
          // Campos de código 6 dígitos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _CodigoBox(
              controller: _ctrls[i],
              focusNode:  _focuses[i],
              onChanged:  (v) => _onCodeInput(i, v),
            )),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _teal))
                : ElevatedButton.icon(
                    onPressed: _codigoCompleto.length == 6 ? _verificarCodigo : null,
                    icon: const Icon(Icons.verified_rounded, size: 20),
                    label: Text('Verificar código',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Reenviar código
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh_rounded, size: 16, color: _teal),
              label: Text('Reenviar código',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: _teal, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );

  // ── Form etapa 2: nova senha ──────────────────────────────────────────────
  Widget _formNovaSenha() => Column(
        key: const ValueKey('f2'),
        children: [
          _CampoSenha(
            controller: _senhaCtrl,
            label: 'NOVA SENHA',
            hint:  'Mínimo 6 caracteres',
            show:  _showSenha,
            onToggle: () => setState(() => _showSenha = !_showSenha),
          ),
          const SizedBox(height: 12),
          _CampoSenha(
            controller: _confirmaCtrl,
            label: 'CONFIRMAR SENHA',
            hint:  'Repita a nova senha',
            show:  _showConfirma,
            onToggle: () => setState(() => _showConfirma = !_showConfirma),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _teal))
                : ElevatedButton.icon(
                    onPressed: _redefinirSenha,
                    icon: const Icon(Icons.lock_rounded, size: 20),
                    label: Text('Redefinir senha',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
          ),
        ],
      );
}

// ── Caixa individual de dígito ─────────────────────────────────────────────
class _CodigoBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _CodigoBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 44, height: 56,
        child: TextField(
          controller:    controller,
          focusNode:     focusNode,
          textAlign:     TextAlign.center,
          maxLength:     1,
          keyboardType:  TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged:     onChanged,
          style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A2E35)),
          decoration: InputDecoration(
            counterText: '',
            filled:      true,
            fillColor:   controller.text.isNotEmpty
                ? const Color(0xFFE0F2F1)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: controller.text.isNotEmpty
                      ? const Color(0xFF00897B)
                      : Colors.grey.shade200,
                  width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: controller.text.isNotEmpty
                      ? const Color(0xFF00897B)
                      : Colors.grey.shade200,
                  width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
            ),
          ),
        ),
      );
}

// ── Campo de senha ────────────────────────────────────────────────────────
class _CampoSenha extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final bool show;
  final VoidCallback onToggle;
  const _CampoSenha({
    required this.controller,
    required this.label,
    required this.hint,
    required this.show,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: .5)),
            const SizedBox(height: 8),
            TextField(
              controller:  controller,
              obscureText: !show,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.lock_outline_rounded,
                    size: 20, color: Colors.grey.shade400),
                suffixIcon: IconButton(
                  icon: Icon(
                    show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20, color: Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
                filled:    true,
                fillColor: const Color(0xFFF4F6F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
              ),
            ),
          ],
        ),
      );
}