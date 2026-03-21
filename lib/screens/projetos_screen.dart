import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/projeto_model.dart';
import '../services/projeto_service.dart';
import '../utils/currency_formatter.dart';

class ProjetosScreen extends StatefulWidget {
  final String token;
  final String usuarioId;
  const ProjetosScreen({super.key, required this.token, this.usuarioId = ''});

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  List<Projeto> _todos      = [];
  bool          _loading    = true;
  bool          _oculto     = true;
  String        _filtro     = 'Todos';
  String        _busca      = '';
  bool          _searchOpen = false;

  static const _teal    = Color(0xFF00897B);
  static const _tealDk  = Color(0xFF00695C);
  static const _filtros = ['Todos', 'Manutenção', 'Lubrificantes', 'Peças', 'Combustível', 'Outros'];
  static const _prefKey = 'projetos_privacidade';

  @override
  void initState() {
    super.initState();
    _carregarPrefs().then((_) => _carregar());
  }

  Future<void> _carregarPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _oculto = p.getBool(_prefKey) ?? true);
  }

  Future<void> _salvarPrefs(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefKey, v);
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final lista = await ProjetoService.listar(widget.token);
      if (mounted) setState(() { _todos = lista; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

List<Projeto> get _filtrados {
    final porCategoria = _filtro == 'Todos'
        ? _todos
        : _todos.where((p) => p.categoria == _filtro).toList();
    if (_busca.isEmpty) return porCategoria;
    return porCategoria.where((p) =>
        p.titulo.toLowerCase().contains(_busca.toLowerCase()) ||
        p.descricao.toLowerCase().contains(_busca.toLowerCase()),
    ).toList();
  }

  double get _totalAplicado => _todos.fold(0, (s, p) => s + p.valorAplicado);

  static const _catColors = {
    'Manutenção': Color(0xFF43A047), 'Lubrificantes': Color(0xFFFB8C00),
    'Peças': Color(0xFF1E88E5),      'Combustível': Color(0xFF00897B),
    'Outros': Color(0xFF9C27B0),
  };

  Color _colorOf(Projeto p) => _catColors[p.categoria] ?? _teal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_teal, _tealDk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total aplicado',
                            style: TextStyle(color: const Color(0xFFB2DFDB), fontSize: 11)),
                        Text(
                          _oculto ? '•••••' : formatBRL(_totalAplicado),
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _IconBtn(icon: Icons.visibility_outlined, onTap: () {
                          setState(() => _oculto = !_oculto);
                          _salvarPrefs(_oculto);
                        }),
                        const SizedBox(width: 10),
                        _IconBtn(
                          icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                          onTap: () => setState(() {
                            _searchOpen = !_searchOpen;
                            if (!_searchOpen) _busca = '';
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                // ✅ Campo de busca (visível quando ativo)
                if (_searchOpen) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setState(() => _busca = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar projeto...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Chips de filtro
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filtros.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final ativo = _filtros[i] == _filtro;
                      return GestureDetector(
                        onTap: () => setState(() => _filtro = _filtros[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: ativo ? Colors.white : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_filtros[i],
                              style: TextStyle(
                                color: ativo ? _teal : Colors.white,
                                fontSize: 12, fontWeight: FontWeight.w700,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Lista ────────────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregar,
              color: _teal,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : _filtrados.isEmpty
                      ? Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.inbox_outlined, size: 64,
                                color: Colors.grey.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              _filtro != 'Todos'
                                  ? 'Sem projetos em "$_filtro"'
                                  : 'Nenhum projeto encontrado',
                              style: const TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtrados.length,
                          itemBuilder: (_, i) => _ProjetoCard(
                            projeto: _filtrados[i],
                            color:   _colorOf(_filtrados[i]),
                            oculto:  _oculto,
                            onTap: () async {
                              await Navigator.pushNamed(
                                context, '/projeto-detalhe',
                                arguments: {
                                  'token':   widget.token,
                                  'projeto': _filtrados[i],
                                },
                              );
                              _carregar();
                            },
                          ),
                        ),
            ),
          ),

          // ── Botão novo ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context, '/novo-projeto',
                  arguments: {'token': widget.token, 'usuarioId': widget.usuarioId},
                ).then((_) => _carregar()),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text('Novo Projeto',
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

// ── Projeto card ──────────────────────────────────────────────────────────────
class _ProjetoCard extends StatelessWidget {
  final Projeto  projeto;
  final Color    color;
  final bool     oculto;
  final VoidCallback onTap;
  const _ProjetoCard({required this.projeto, required this.color, required this.oculto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prog      = (projeto.progresso / 100).clamp(0.0, 1.0);
    final concluido = prog >= 1.0;
    final restante  = projeto.valorNecessario - projeto.valorAplicado;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: concluido ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: concluido ? Border.all(color: color.withValues(alpha: 0.5), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.8),
                    child: Text(projeto.titulo[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(projeto.titulo,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                                color: concluido ? color : const Color(0xFF263238)),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(6)),
                          child: Text(projeto.categoria,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
                        ),
                      ],
                    ),
                  ),
                  if (concluido)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text('✅ Concluído',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ValCol('Necessário', projeto.valorNecessario, oculto),
                  _ValCol('Aplicado',   projeto.valorAplicado,   oculto),
                  _ValCol('Restante',   restante,                oculto),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prog, minHeight: 8,
                  backgroundColor: const Color(0xFFECEFF1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${projeto.progresso.toStringAsFixed(1)}% concluído',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValCol extends StatelessWidget {
  final String label;
  final double value;
  final bool   oculto;
  const _ValCol(this.label, this.value, this.oculto);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: Color(0xFF90A4AE), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(oculto ? '•••••' : formatBRL(value),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
        ],
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