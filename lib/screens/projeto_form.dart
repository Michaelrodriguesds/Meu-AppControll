import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/projeto_model.dart';
import '../services/projeto_service.dart';
import '../utils/network_checker.dart';

class ProjetoForm extends StatefulWidget {
  final String   token;
  final String   usuarioId;
  final Projeto? projeto;

  const ProjetoForm({
    super.key,
    required this.token,
    required this.usuarioId,
    this.projeto,
  });

  @override
  State<ProjetoForm> createState() => _ProjetoFormState();
}

class _ProjetoFormState extends State<ProjetoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descricaoCtrl;
  late TextEditingController _valorCtrl;
  String    _categoriaSel = '';
  DateTime? _dataInicio;
  bool      _loading      = false;

  bool get isEdit => widget.projeto != null;

  static const _teal   = Color(0xFF00897B);
  static const _tealDk = Color(0xFF00695C);

  static const _cats = [
    'Manutencao', 'Pecas', 'Lubrificantes', 'Combustivel', 'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _tituloCtrl    = TextEditingController(text: widget.projeto?.titulo    ?? '');
    _descricaoCtrl = TextEditingController(text: widget.projeto?.descricao ?? '');
    _valorCtrl     = TextEditingController(
      text: widget.projeto?.valorNecessario != null
          ? widget.projeto!.valorNecessario.toStringAsFixed(2)
          : '',
    );
    _dataInicio = widget.projeto?.dataInicio ?? DateTime.now();
    if (widget.projeto != null) _categoriaSel = widget.projeto!.categoria;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dataInicio!,
      firstDate: DateTime(2000),
      lastDate:  DateTime(2100),
    );
    if (d != null) setState(() => _dataInicio = d);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSel.isEmpty) {
      _snack('Selecione uma categoria', error: true);
      return;
    }

    final ok = await NetworkChecker.isOnline();
    if (!mounted) return;
    if (!ok) { _snack('Sem conexao com a internet', error: true); return; }

    setState(() => _loading = true);
    final vn = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0.0;

    final projeto = Projeto(
      id:              widget.projeto?.id,
      titulo:          _tituloCtrl.text.trim(),
      descricao:       _descricaoCtrl.text.trim(),
      categoria:       _categoriaSel,
      valorNecessario: vn,
      // Preserva o valor ja aplicado — nunca sobrescreve com 0
      valorAplicado:   widget.projeto?.valorAplicado ?? 0.0,
      dataInicio:      _dataInicio!,
      usuarioId:       widget.usuarioId,
      progresso:       widget.projeto?.progresso ?? 0.0,
    );

    try {
      if (isEdit) {
        await ProjetoService.atualizar(projeto, widget.token);
      } else {
        await ProjetoService.criar(projeto, widget.token);
      }
      if (!mounted) return;
      _snack(isEdit ? 'Projeto atualizado!' : 'Projeto criado!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack('Erro: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : _teal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_teal, _tealDk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                        Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  isEdit ? 'Editar Projeto' : 'Novo Projeto',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Título
                    _Campo(
                      icon: Icons.push_pin_rounded,
                      label: 'TITULO',
                      child: TextFormField(
                        controller: _tituloCtrl,
                        decoration: _dec('Nome do projeto...'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o titulo'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Descrição
                    _Campo(
                      icon: Icons.description_rounded,
                      label: 'DESCRICAO',
                      child: TextFormField(
                        controller: _descricaoCtrl,
                        maxLines: 3,
                        decoration: _dec('Descreva o objetivo...'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe a descricao'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categoria — chips
                    _Campo(
                      icon: Icons.category_rounded,
                      label: 'CATEGORIA',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cats.map((cat) {
                          final sel = cat == _categoriaSel;
                          return GestureDetector(
                            onTap: () => setState(() => _categoriaSel = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? _teal
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: sel
                                    ? [BoxShadow(
                                        color: _teal.withValues(alpha: 0.3),
                                        blurRadius: 8)]
                                    : [],
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? Colors.white
                                      : const Color(0xFF607D8B),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Valor necessário
                    _Campo(
                      icon: Icons.attach_money_rounded,
                      label: 'VALOR NECESSARIO (META)',
                      child: TextFormField(
                        controller: _valorCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: _dec('R\$ 0,00'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o valor';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) {
                            return 'Valor invalido';
                          }
                          return null;
                        },
                      ),
                    ),

                    // ── Valor já aplicado (só aparece ao editar) ───────────
                    if (isEdit && (widget.projeto?.valorAplicado ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.savings_rounded,
                                size: 15, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Valor ja aplicado: R\$ '
                                '${widget.projeto!.valorAplicado.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Nota: use Depositar para adicionar valores ─────────
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 15, color: Color(0xFF854F0B)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Para adicionar valores, use o botao Depositar na tela do projeto.',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF854F0B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Data de início
                    _Campo(
                      icon: Icons.calendar_today_rounded,
                      label: 'DATA DE INICIO',
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_dataInicio!.day.toString().padLeft(2, '0')}/'
                                '${_dataInicio!.month.toString().padLeft(2, '0')}/'
                                '${_dataInicio!.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _teal,
                                ),
                              ),
                              const Icon(Icons.edit_calendar_rounded,
                                  color: Color(0xFF90A4AE), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão salvar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(color: _teal))
                          : ElevatedButton.icon(
                              onPressed: _salvar,
                              icon: Icon(isEdit
                                  ? Icons.save_rounded
                                  : Icons.add_circle_rounded),
                              label: Text(
                                isEdit
                                    ? 'Salvar Alteracoes'
                                    : '+ Criar Projeto',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _teal,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText:  hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        filled:    true,
        fillColor: const Color(0xFFF4F6F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF00897B), width: 1.5)),
      );
}

// ── Campo com label e ícone ───────────────────────────────────────────────────
class _Campo extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Widget   child;
  const _Campo(
      {required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 14, color: const Color(0xFF90A4AE)),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF90A4AE),
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5)),
            ]),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
}