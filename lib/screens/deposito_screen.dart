import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/projeto_model.dart';
import '../models/transacao_model.dart';
import '../services/projeto_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/valor_chip.dart';
import '../widgets/progresso_card.dart';

class DepositoScreen extends StatefulWidget {
  final String  token;
  final Projeto projeto;

  const DepositoScreen({super.key, required this.token, required this.projeto});

  @override
  State<DepositoScreen> createState() => _DepositoScreenState();
}

class _DepositoScreenState extends State<DepositoScreen> {
  final _valorCtrl = TextEditingController();
  final _notaCtrl  = TextEditingController();

  double?    _selectedChip;
  bool       _loading = false;
  String     _error   = '';

  static const _chips  = [10.0, 50.0, 100.0, 200.0];
  static const _teal   = Color(0xFF00897B);

  double get _valorDigitado {
    final raw = _valorCtrl.text.replaceAll(',', '.');
    return double.tryParse(raw) ?? 0.0;
  }

  double get _valorAporte => _selectedChip ?? _valorDigitado;

  double get _novoValor   => widget.projeto.valorAplicado + _valorAporte;

  double get _novoProgresso {
    final req = widget.projeto.valorNecessario;
    if (req <= 0) return 0;
    return (_novoValor / req * 100).clamp(0, 100);
  }

  bool get _valido => _valorAporte > 0;

  void _selectChip(double v) {
    setState(() {
      _selectedChip = _selectedChip == v ? null : v;
      if (_selectedChip != null) _valorCtrl.clear();
    });
  }

  void _onTyped(String v) {
    setState(() => _selectedChip = null);
  }

  Future<void> _confirmar() async {
    if (!_valido) {
      setState(() => _error = 'Digite ou selecione um valor');
      return;
    }
    setState(() { _loading = true; _error = ''; });

    try {
      final resp = await ProjetoService.depositar(
        projectId: widget.projeto.id!,
        amount:    _valorAporte,
        token:     widget.token,
        note:      _notaCtrl.text.trim(),
      );

      // Build updated projeto to pass back
      final tx = Transacao(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: widget.projeto.id!,
        amount:    resp.deposited,
        note:      _notaCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      final updated = widget.projeto.copyWithDeposit(
        newValue:   resp.newValue,
        progress:   resp.progress,
        transacao:  tx,
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccess(resp);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (mounted) Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showSuccess(DepositResponse resp) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _teal,
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Text('${formatBRL(resp.deposited)} depositado com sucesso!',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Depositar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Project info bar ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF00695C)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.projeto.titulo,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('Atual: ${formatBRL(widget.projeto.valorAplicado)} · Meta: ${formatBRL(widget.projeto.valorNecessario)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick chips ─────────────────────────────────────────────────
            Text('Valor rápido',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _chips.map((v) => ValorChip(
                value:    v,
                selected: _selectedChip == v,
                onTap:    () => _selectChip(v),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // ── Manual input ────────────────────────────────────────────────
            Text('Ou digite o valor',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('R\$', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: _teal)),
                  ),
                  Expanded(
                    child: TextField(
                      controller:   _valorCtrl,
                      onChanged:    _onTyped,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        hintText: '0,00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Note ────────────────────────────────────────────────────────
            TextField(
              controller:  _notaCtrl,
              maxLength:   80,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Observação (opcional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.sticky_note_2_outlined, size: 20, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _teal, width: 1.5)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Preview before / after ──────────────────────────────────────
            if (_valido) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _teal.withValues(alpha: 0.3)),
                  boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.06), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prévia do Aporte',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PreviewRow(label: 'Antes', value: formatBRL(widget.projeto.valorAplicado),
                            progress: widget.projeto.progresso, color: Colors.grey),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                        _PreviewRow(label: 'Depois', value: formatBRL(_novoValor),
                            progress: _novoProgresso, color: _teal),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ProgressoCard(progress: _novoProgresso, color: _teal),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Error ────────────────────────────────────────────────────────
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),

            // ── Confirm button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : ElevatedButton(
                      onPressed: _valido ? _confirmar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _valido
                            ? 'Confirmar Depósito de ${formatBRL(_valorAporte)}'
                            : 'Selecione ou digite um valor',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label, value;
  final double progress;
  final Color  color;

  const _PreviewRow({required this.label, required this.value, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(value,  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text('${progress.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: color)),
        ],
      );
}