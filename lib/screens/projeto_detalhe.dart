import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/projeto_model.dart';
import '../models/transacao_model.dart';
import '../services/transacao_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/progresso_card.dart';
import '../widgets/transacao_tile.dart';

class ProjetoDetalheScreen extends StatefulWidget {
  final String  token;
  final Projeto projeto;

  const ProjetoDetalheScreen({super.key, required this.token, required this.projeto});

  @override
  State<ProjetoDetalheScreen> createState() => _ProjetoDetalheScreenState();
}

class _ProjetoDetalheScreenState extends State<ProjetoDetalheScreen> {
  late Projeto _projeto;
  List<Transacao> _transacoes = [];
  bool _loadingTx = true;

  static const _catColors = {
    'Manutenção': Color(0xFF1E88E5),
    'Lubrificantes': Color(0xFFFB8C00),
    'Peças': Color(0xFF8E24AA),
    'Combustível': Color(0xFF43A047),
    'Outros': Color(0xFF00897B),
  };

  @override
  void initState() {
    super.initState();
    _projeto = widget.projeto;
    _loadTransacoes();
  }

  Future<void> _loadTransacoes() async {
    try {
      final list = await TransacaoService.listar(_projeto.id!, widget.token);
      if (mounted) setState(() { _transacoes = list; _loadingTx = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTx = false);
    }
  }

  Future<void> _abrirDeposito() async {
    final result = await Navigator.pushNamed(
      context, '/deposito',
      arguments: {'token': widget.token, 'projeto': _projeto},
    );

    // If deposit was made, result is the updated Projeto
    if (result is Projeto && mounted) {
      setState(() {
        _projeto = result;
        // Add new transaction at top of list
        if (result.transacoes.isNotEmpty) {
          _transacoes = [result.transacoes.first, ..._transacoes];
        }
      });
    }
  }

  Color get _color => _catColors[_projeto.categoria] ?? const Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context, _projeto),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_color, _color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_projeto.categoria,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 8),
                        Text(_projeto.titulo,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(_projeto.descricao,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress card ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Stat(label: 'Investido',  value: formatBRL(_projeto.valorAplicado), color: _color),
                            _Stat(label: 'Restante',   value: formatBRL(_projeto.valorRestante), color: Colors.grey),
                            _Stat(label: 'Meta',       value: formatBRL(_projeto.valorNecessario), color: Colors.grey.shade800),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProgressoCard(progress: _projeto.progresso, color: _color),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Deposit button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _projeto.concluido ? null : _abrirDeposito,
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                      label: Text(
                        _projeto.concluido ? '✅ Projeto Concluído' : '＋ Depositar',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _projeto.concluido ? Colors.grey.shade300 : _color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Transaction history ─────────────────────────────────
                  Text('Histórico de Aportes',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  if (_loadingTx)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)))
                  else if (_transacoes.isEmpty)
                    _EmptyTx()
                  else
                    ...(_transacoes.map((t) => TransacaoTile(transacao: t))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}

class _EmptyTx extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, color: Colors.grey.shade300, size: 32),
            const SizedBox(width: 12),
            Text('Nenhum aporte ainda.\nToque em Depositar para começar!',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );
}