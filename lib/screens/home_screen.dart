import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/projeto_model.dart';
import '../services/usuario_service.dart';
import '../services/projeto_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String usuarioId;

  const HomeScreen({super.key, required this.token, required this.usuarioId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nome          = '';
  String _email         = '';
  String _tema          = '';
  bool   _carregando    = true;
  bool   _valoresOcultos = true;
  int    _navIndex      = 0;

  List<Projeto> _projetos   = [];
  double _totalInvestido    = 0.0;

  static const _teal    = Color(0xFF00897B);
  static const _tealDk  = Color(0xFF00695C);
  static const _prefKey = 'privacidade_ativada';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _valoresOcultos = prefs.getBool(_prefKey) ?? true);
    await Future.wait([_carregarUsuario(), _carregarProjetos()]);
  }

  Future<void> _carregarUsuario() async {
    try {
      final data = await UsuarioService.getUsuarioPorId(widget.usuarioId);
      if (mounted && data != null) {
        setState(() {
          _nome      = data['name']  ?? '';
          _email     = data['email'] ?? '';
          _tema      = data['theme'] ?? 'light';
          _carregando = false;
        });
      } else if (mounted) {
        setState(() => _carregando = false);
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarProjetos() async {
    try {
      final lista = await ProjetoService.listar(widget.token);
      if (mounted) {
        setState(() {
          _projetos      = lista;
          _totalInvestido = lista.fold(0, (s, p) => s + p.valorAplicado);
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar projetos: $e');
    }
  }

  Future<void> _salvarPrivacidade(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, v);
  }

  Future<void> _refresh() => Future.wait([_carregarUsuario(), _carregarProjetos()]);

  void _navegar(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/projetos',
            arguments: {'token': widget.token, 'usuarioId': widget.usuarioId});
        break;
      case 2:
        Navigator.pushNamed(context, '/estatisticas',
            arguments: {'token': widget.token});
        break;
      case 3:
        Navigator.pushNamed(context, '/anotacoes',
            arguments: {'token': widget.token, 'usuarioId': widget.usuarioId});
        break;
      case 4:
        Navigator.pushNamed(context, '/perfil',
            arguments: {'token': widget.token, 'usuarioId': widget.usuarioId});
        break;
    }
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: BottomNav(currentIndex: _navIndex, onTap: _navegar),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: _teal,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildAcoesRapidas()),
                  SliverToBoxAdapter(child: _buildRecentesHeader()),
                  if (_projetos.isEmpty)
                    SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _ProjetoCard(
                            projeto: _projetos[i],
                            oculto:  _valoresOcultos,
                            onTap: () => Navigator.pushNamed(
                              context, '/projeto-detalhe',
                              arguments: {'token': widget.token, 'projeto': _projetos[i]},
                            ).then((_) => _carregarProjetos()),
                          ),
                          childCount: _projetos.length > 3 ? 3 : _projetos.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // ── Header gradiente ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal, _tealDk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Olá, 👋', style: GoogleFonts.poppins(color: const Color(0xFFB2DFDB), fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(_nome.isNotEmpty ? _nome : 'Carregando...',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _valoresOcultos ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white70, size: 22,
                    ),
                    onPressed: () {
                      setState(() => _valoresOcultos = !_valoresOcultos);
                      _salvarPrivacidade(_valoresOcultos);
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Text(
                        _nome.isNotEmpty ? _nome[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: _teal, fontSize: 18),
                      ),
                    ),
                    onSelected: (v) {
                      if (v == 'config') {
                        Navigator.pushNamed(context, '/configuracoes', arguments: {
                          'token': widget.token, 'nome': _nome,
                          'email': _email, 'theme': _tema,
                        });
                      } else if (v == 'logout') {
                        _confirmarLogout();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'config',
                          child: ListTile(leading: Icon(Icons.settings_rounded), title: Text('Configurações'))),
                      PopupMenuItem(value: 'logout',
                          child: ListTile(leading: Icon(Icons.logout_rounded), title: Text('Sair'))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Resumo financeiro ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo Financeiro',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Total investido
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL INVESTIDO',
                                style: TextStyle(color: const Color(0xFFB2DFDB), fontSize: 10, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              _valoresOcultos ? '•••••' : formatBRL(_totalInvestido),
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Projetos — clicável
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navegar(1),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('PROJETOS',
                                      style: TextStyle(color: const Color(0xFFB2DFDB), fontSize: 10, fontWeight: FontWeight.w500)),
                                  const Icon(Icons.arrow_outward_rounded, color: Color(0xFFB2DFDB), size: 14),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${_projetos.length} ativos',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text('Toque para ver todos',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 9, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ações rápidas 2x2 ────────────────────────────────────────────────────────
  Widget _buildAcoesRapidas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
        children: [
          _AcaoCard(icon: Icons.add_circle_rounded,   label: 'Novo Projeto',   iconColor: const Color(0xFF43A047),
              onTap: () => Navigator.pushNamed(context, '/novo-projeto',
                  arguments: {'token': widget.token, 'usuarioId': widget.usuarioId})
                  .then((_) => _carregarProjetos())),
          _AcaoCard(icon: Icons.edit_note_rounded,    label: 'Nova Anotação',  iconColor: const Color(0xFF1E88E5),
              onTap: () => Navigator.pushNamed(context, '/nova-anotacao',
                  arguments: {'token': widget.token, 'usuarioId': widget.usuarioId})),
          _AcaoCard(icon: Icons.bar_chart_rounded,    label: 'Estatísticas',   iconColor: const Color(0xFFFB8C00),
              onTap: () => _navegar(2)),
          _AcaoCard(icon: Icons.notifications_rounded, label: 'Anotações',     iconColor: const Color(0xFFE53935),
              onTap: () => _navegar(3)),
        ],
      ),
    );
  }

  Widget _buildRecentesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Projetos Recentes',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF455A64))),
          TextButton(
            onPressed: () => _navegar(1),
            child: const Text('Ver todos', style: TextStyle(color: _teal, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Nenhum projeto ainda',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/novo-projeto',
                  arguments: {'token': widget.token, 'usuarioId': widget.usuarioId}),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Criar primeiro projeto'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      );
}

// ── Widgets locais ─────────────────────────────────────────────────────────────
class _AcaoCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    iconColor;
  final VoidCallback onTap;
  const _AcaoCard({required this.icon, required this.label, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF263238))),
              ),
            ],
          ),
        ),
      );
}

class _ProjetoCard extends StatelessWidget {
  final Projeto projeto;
  final bool    oculto;
  final VoidCallback onTap;
  const _ProjetoCard({required this.projeto, required this.oculto, required this.onTap});

  static const _catColors = {
    'Manutenção': Color(0xFF43A047), 'Lubrificantes': Color(0xFFFB8C00),
    'Peças': Color(0xFF1E88E5),      'Combustível': Color(0xFF00897B),
    'Outros': Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[projeto.categoria] ?? const Color(0xFF00897B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(projeto.titulo[0].toUpperCase(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(projeto.titulo,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF263238))),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value:           (projeto.progresso / 100).clamp(0.0, 1.0),
                      minHeight:       6,
                      backgroundColor: const Color(0xFFECEFF1),
                      valueColor:      AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('${projeto.progresso.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}