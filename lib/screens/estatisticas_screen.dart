import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stats_model.dart';
import '../services/stats_service.dart';
import '../utils/currency_formatter.dart';

class EstatisticasScreen extends StatefulWidget {
  final String token;
  const EstatisticasScreen({super.key, required this.token});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  StatsSummary? _stats;
  bool _loading = true;
  String _error  = '';

  static const _teal = Color(0xFF00897B);

  static const _catColors = [
    Color(0xFF00897B), Color(0xFF1E88E5), Color(0xFFFB8C00),
    Color(0xFF8E24AA), Color(0xFF43A047), Color(0xFFEF5350),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final stats = await StatsService.buscar(widget.token);
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erro ao carregar estatísticas'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Estatísticas', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _error.isNotEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.grey, size: 48),
                    const SizedBox(height: 12),
                    Text(_error, style: const TextStyle(color: Colors.grey)),
                    TextButton(onPressed: _load, child: const Text('Tentar novamente')),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _teal,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Summary cards ─────────────────────────────────
                        Row(
                          children: [
                            _SummaryCard(label: 'Total Investido', value: formatBRL(_stats!.totalInvested), color: _teal, icon: Icons.trending_up_rounded),
                            const SizedBox(width: 12),
                            _SummaryCard(label: 'Total Geral', value: formatBRL(_stats!.grandTotal), color: const Color(0xFF1E88E5), icon: Icons.account_balance_wallet_rounded),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Bar chart ─────────────────────────────────────
                        if (_stats!.monthly.isNotEmpty) ...[
                          Text('Gastos por Mês',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            child: _BarChart(monthly: _stats!.monthly),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Category breakdown ────────────────────────────
                        if (_stats!.byCategory.isNotEmpty) ...[
                          Text('Por Categoria',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              children: List.generate(_stats!.byCategory.length, (i) {
                                final cat   = _stats!.byCategory[i];
                                final color = _catColors[i % _catColors.length];
                                return _CategoryRow(stat: cat, color: color);
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Top expenses ──────────────────────────────────
                        if (_stats!.topExpenses.isNotEmpty) ...[
                          Text('Maiores Gastos',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          ...(_stats!.topExpenses.asMap().entries.map((e) => _TopTile(
                                rank:    e.key + 1,
                                expense: e.value,
                              ))),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color  color;
  final IconData icon;

  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
}

// ── Simple bar chart ─────────────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<MonthlyStat> monthly;
  const _BarChart({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final maxVal = monthly.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthly.map((m) {
          final ratio = maxVal > 0 ? m.total / maxVal : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(formatBRL(m.total).replaceAll('R\$\u00a0', ''),
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF00897B)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: 100 * ratio,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00897B), Color(0xFF00BFA5)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.month, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryStat stat;
  final Color color;
  const _CategoryRow({required this.stat, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(stat.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                Text('${formatBRL(stat.total)} · ${stat.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value:           stat.percentage / 100,
                minHeight:       7,
                backgroundColor: Colors.grey.shade100,
                valueColor:      AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      );
}

class _TopTile extends StatelessWidget {
  final int rank;
  final TopExpense expense;

  static const _rankColors = [Color(0xFFFFD700), Color(0xFFB0BEC5), Color(0xFFFF8C00)];

  const _TopTile({required this.rank, required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = rank <= 3 ? _rankColors[rank - 1] : Colors.grey.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Text('$rank', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(expense.source == 'note' ? 'Anotação' : 'Projeto',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(formatBRL(expense.amount),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF00897B))),
        ],
      ),
    );
  }
}