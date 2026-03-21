import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';
import '../utils/network_checker.dart';
import '../utils/notificacao_service.dart';

class AnotacaoForm extends StatefulWidget {
  final String   usuarioId;
  final String   token;
  final Anotacao? anotacao;

  const AnotacaoForm({
    super.key,
    required this.usuarioId,
    required this.token,
    this.anotacao,
  });

  @override
  State<AnotacaoForm> createState() => _AnotacaoFormState();
}

class _AnotacaoFormState extends State<AnotacaoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _conteudoCtrl;
  DateTime? _dataSelecionada;
  DateTime? _lembreteSelecionado;

  static const _teal   = Color(0xFF00897B);
  static const _tealDk = Color(0xFF00695C);

  bool get isEdit => widget.anotacao != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl   = TextEditingController(text: widget.anotacao?.titulo   ?? '');
    _conteudoCtrl = TextEditingController(text: widget.anotacao?.conteudo ?? '');
    _dataSelecionada     = widget.anotacao?.data;
    _lembreteSelecionado = widget.anotacao?.lembrete;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final sel = await showDatePicker(
      context: context, initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (sel != null) setState(() => _dataSelecionada = sel);
  }

  Future<void> _selecionarLembrete() async {
    final agora = DateTime.now();
    final data  = await showDatePicker(
      context: context, initialDate: _lembreteSelecionado ?? agora,
      firstDate: agora, lastDate: DateTime(2100),
    );
    if (data == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_lembreteSelecionado ?? agora),
    );
    if (hora == null) return;
    setState(() => _lembreteSelecionado =
        DateTime(data.year, data.month, data.day, hora.hour, hora.minute));
  }

  Future<void> _salvar() async {
    final ok = await NetworkChecker.isOnline();
    if (!mounted) return;
    if (!ok) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexao'), backgroundColor: Colors.red));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final anotacao = Anotacao(
      id: widget.anotacao?.id, titulo: _tituloCtrl.text.trim(),
      conteudo: _conteudoCtrl.text.trim(), data: _dataSelecionada,
      lembrete: _lembreteSelecionado, usuarioId: widget.usuarioId,
    );

    try {
      if (isEdit) {
        await AnotacaoService.atualizar(anotacao, widget.token);
      } else {
        await AnotacaoService.criar(anotacao, widget.token);
      }
      if (_lembreteSelecionado != null && _lembreteSelecionado!.isAfter(DateTime.now())) {
        try {
          await NotificacaoService.agendarNotificacao(
            'Lembrete: ${_tituloCtrl.text}', _conteudoCtrl.text, _lembreteSelecionado!);
        } catch (_) {}
      }
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  String _fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  String _fmtLembrete(DateTime d) =>
      '${_fmtData(d)} as ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_teal, _tealDk],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Text(isEdit ? 'Editar Anotacao' : 'Nova Anotacao',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Campo(icon: Icons.title_rounded, label: 'TITULO',
                  child: TextFormField(controller: _tituloCtrl, decoration: _dec('Nome da anotacao...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o titulo' : null)),
                const SizedBox(height: 12),
                _Campo(icon: Icons.notes_rounded, label: 'CONTEUDO',
                  child: TextFormField(controller: _conteudoCtrl, maxLines: 6,
                    decoration: _dec('Detalhes, valores, observacoes...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o conteudo' : null)),
                const SizedBox(height: 12),
                _Campo(icon: Icons.event_note_rounded, label: 'DATA DA ANOTACAO',
                  child: GestureDetector(
                    onTap: _selecionarData,
                    child: _DateRow(
                      texto: _dataSelecionada != null ? _fmtData(_dataSelecionada!) : 'Nenhuma data',
                      icon: Icons.edit_calendar_rounded, ativo: _dataSelecionada != null))),
                const SizedBox(height: 12),
                _Campo(icon: Icons.alarm_rounded, label: 'LEMBRETE (OPCIONAL)',
                  child: GestureDetector(
                    onTap: _selecionarLembrete,
                    child: _DateRow(
                      texto: _lembreteSelecionado != null
                          ? _fmtLembrete(_lembreteSelecionado!)
                          : 'Toque para agendar',
                      icon: Icons.access_time_rounded,
                      ativo: _lembreteSelecionado != null,
                      iconColor: _lembreteSelecionado != null ? const Color(0xFFFB8C00) : null))),
                if (_lembreteSelecionado != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _lembreteSelecionado = null),
                    child: const Row(children: [
                      SizedBox(width: 4),
                      Icon(Icons.close_rounded, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Remover lembrete', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                    label: Text(isEdit ? 'Salvar Alteracoes' : 'Criar Anotacao',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
    filled: true, fillColor: const Color(0xFFF4F6F9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
  );
}

class _Campo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _Campo({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: const Color(0xFF90A4AE)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE),
            fontWeight: FontWeight.w700, letterSpacing: .5)),
      ]),
      const SizedBox(height: 8),
      child,
    ]),
  );
}

class _DateRow extends StatelessWidget {
  final String texto;
  final IconData icon;
  final bool ativo;
  final Color? iconColor;
  const _DateRow({required this.texto, required this.icon, this.ativo = false, this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Expanded(child: Text(texto, style: TextStyle(
        fontSize: 14, fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
        color: ativo ? (iconColor ?? const Color(0xFF00897B)) : const Color(0xFFB0BEC5)))),
      Icon(icon, color: ativo ? (iconColor ?? const Color(0xFF00897B)) : Colors.grey.shade400, size: 18),
    ]),
  );
}