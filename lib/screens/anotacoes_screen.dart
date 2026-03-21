import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';
import '../utils/notificacao_service.dart';

class AnotacoesScreen extends StatefulWidget {
  final String usuarioId;
  final String token;
  const AnotacoesScreen({super.key, required this.usuarioId, required this.token});

  @override
  State<AnotacoesScreen> createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends State<AnotacoesScreen> {
  List<Anotacao> _anotacoes    = [];
  bool           _loading      = true;
  bool           _mostrarConteudo = false;
  String         _busca           = '';

  static const _teal   = Color(0xFF00897B);
  static const _tealDk = Color(0xFF00695C);

  // Tag → cor
  static const _tagColors = {
    'Compra':     Color(0xFF1E88E5),
    'Peça':       Color(0xFF43A047),
    'Manutenção': Color(0xFFFB8C00),
    'Serviço':    Color(0xFF9C27B0),
    'Outro':      Color(0xFF00897B),
  };

  String _detectarTag(Anotacao a) {
    final txt = '${a.titulo ?? ""} ${a.conteudo ?? ""}'.toLowerCase();
    if (txt.contains('compra') || txt.contains('comprei')) return 'Compra';
    if (txt.contains('peça') || txt.contains('peca') || txt.contains('bateria')) return 'Peça';
    if (txt.contains('manutenção') || txt.contains('manutencao') || txt.contains('alternador')) return 'Manutenção';
    if (txt.contains('serviço') || txt.contains('mão de obra') || txt.contains('troca')) return 'Serviço';
    return 'Outro';
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final lista = await AnotacaoService.listar(widget.token);
      if (mounted) {
        setState(() { _anotacoes = lista; _loading = false; });
        _agendarNotificacoes(lista);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _agendarNotificacoes(List<Anotacao> lista) async {
    for (final a in lista) {
      if (a.lembrete != null && a.lembrete!.isAfter(DateTime.now())) {
        try {
          await NotificacaoService.agendarNotificacao(
            'Lembrete: ${a.titulo ?? "Sem título"}', a.conteudo ?? '', a.lembrete!,
          );
        } catch (_) {}
      }
    }
  }

  void _verDetalhes(Anotacao a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,   // ✅ permite altura dinâmica
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(a.titulo ?? 'Sem título',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              Text(a.conteudo ?? '',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF607D8B), height: 1.6)),
              if (a.lembrete != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.alarm, size: 16, color: _teal),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(a.lembrete!),
                        style: const TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(Anotacao a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: const Text('Deseja excluir esta anotação?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await AnotacaoService.deletar(a.id!, widget.token);
      if (!mounted) return;
      _carregar();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anotação excluída.'), backgroundColor: _teal));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }


  List<Anotacao> get _filtradas => _busca.isEmpty
      ? _anotacoes
      : _anotacoes.where((a) =>
          (a.titulo  ?? '').toLowerCase().contains(_busca.toLowerCase()) ||
          (a.conteudo ?? '').toLowerCase().contains(_busca.toLowerCase()),
        ).toList();

  @override
  Widget build(BuildContext context) {
    final total = _anotacoes.length;
    final lembretes = _anotacoes.where((a) => a.lembrete != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_teal, _tealDk],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // ✅ Botão voltar ao menu
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (_) => false,
                          arguments: {'token': widget.token, 'usuarioId': widget.usuarioId}),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Minhas Anotações',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    _IconBtn(
                      icon: _mostrarConteudo ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      onTap: () => setState(() => _mostrarConteudo = !_mostrarConteudo),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ✅ Campo de busca funcional
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _busca = v),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar anotação...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Resumo rápido ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _ResumoChip(icon: '📝', texto: '$total notas',    bg: const Color(0xFFE3F2FD), cor: const Color(0xFF1E88E5)),
                const SizedBox(width: 10),
                _ResumoChip(icon: '🔔', texto: '$lembretes lembretes', bg: const Color(0xFFFFF8E1), cor: const Color(0xFFFB8C00)),
              ],
            ),
          ),

          // ── Lista ─────────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregar,
              color: _teal,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : _anotacoes.isEmpty
                      ? const Center(child: Text('Nenhuma anotação encontrada.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _filtradas.length,
                          itemBuilder: (_, i) {
                            final a    = _filtradas[i];
                            final tag  = _detectarTag(a);
                            final cor  = _tagColors[tag] ?? _teal;
                            final data = a.data != null
                                ? DateFormat('dd/MM/yyyy').format(a.data!)
                                : null;
                            final lembrete = a.lembrete != null
                                ? DateFormat('dd/MM/yyyy HH:mm').format(a.lembrete!)
                                : null;

                            return GestureDetector(
                              onTap: () => _verDetalhes(a),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border(left: BorderSide(color: cor, width: 4)),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(a.titulo ?? 'Sem título',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF263238))),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: cor.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(8)),
                                            child: Text(tag,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cor)),
                                          ),
                                          const SizedBox(width: 6),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                                            onSelected: (v) {
                                              if (v == 'editar') {
                                                Navigator.pushNamed(context, '/nova-anotacao', arguments: {
                                                  'anotacao': a, 'usuarioId': widget.usuarioId, 'token': widget.token,
                                                }).then((r) { if (r == true) _carregar(); });
                                              } else if (v == 'excluir') {
                                                _confirmarExclusao(a);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(value: 'editar',  child: Text('Editar')),
                                              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _mostrarConteudo ? (a.conteudo ?? '') : '• • • • • • • • • • • • •',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _mostrarConteudo ? const Color(0xFF607D8B) : Colors.grey.shade400,
                                          fontStyle: _mostrarConteudo ? FontStyle.normal : FontStyle.italic,
                                        ),
                                        maxLines: 3, overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          if (data != null) ...[
                                            const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFFB0BEC5)),
                                            const SizedBox(width: 4),
                                            Text(data, style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5))),
                                          ],
                                          const Spacer(),
                                          if (lembrete != null) ...[
                                            const Icon(Icons.alarm_rounded, size: 14, color: _teal),
                                            const SizedBox(width: 4),
                                            Text(lembrete, style: const TextStyle(fontSize: 11, color: _teal)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),

          // ── Botão nova ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final r = await Navigator.pushNamed(
                    context, '/nova-anotacao',
                    arguments: {'usuarioId': widget.usuarioId, 'token': widget.token},
                  );
                  if (!mounted) return;
                  if (r == true) {
                    _carregar();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anotação criada!'), backgroundColor: _teal));
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text('Nova Anotação',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoChip extends StatelessWidget {
  final String icon, texto;
  final Color bg, cor;
  const _ResumoChip({required this.icon, required this.texto, required this.bg, required this.cor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
        ]),
      );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}