import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../utils/currency_formatter.dart';

class PerfilScreen extends StatefulWidget {
  final String token;
  final String usuarioId;

  const PerfilScreen({super.key, required this.token, required this.usuarioId});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  bool _loading     = true;
  bool _isDarkTheme = false;

  static const _teal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final usuario = await UsuarioService.obterPerfil(widget.token);
      if (mounted) setState(() { _usuario = usuario; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar perfil: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sair da conta"),
        content: const Text("Tem certeza que deseja sair?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false),
            child: const Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: const Text("Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _usuario == null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text("Perfil nao encontrado", style: TextStyle(color: Colors.grey)),
                    TextButton(onPressed: _carregar, child: const Text("Tentar novamente")),
                  ]),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Column(children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: _teal.withValues(alpha: 0.15),
                          child: Text(
                            _usuario!.nome.isNotEmpty ? _usuario!.nome[0].toUpperCase() : "U",
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _teal),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_usuario!.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_usuario!.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ]),
                    ),
                    const SizedBox(height: 28),
                    _InfoCard(icon: Icons.trending_up_rounded, label: "Total Investido",  value: formatBRL(_usuario!.totalInvestido), color: _teal),
                    const SizedBox(height: 12),
                    _InfoCard(icon: Icons.folder_rounded,       label: "Projetos Ativos", value: "${_usuario!.projetosAtivos}",         color: const Color(0xFF1E88E5)),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.brightness_6_rounded, label: "Tema",
                      value: _isDarkTheme ? "Escuro" : "Claro", color: const Color(0xFFFB8C00),
                      trailing: Switch(value: _isDarkTheme, onChanged: (v) => setState(() => _isDarkTheme = v), activeThumbColor: _teal),
                    ),
                    const SizedBox(height: 28),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, "/configuracoes", arguments: {
                        "token": widget.token, "nome": _usuario!.nome, "email": _usuario!.email, "theme": _usuario!.tema,
                      }),
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text("Configuracoes", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: _teal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Sair da Conta", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  final Color    color;
  final Widget?  trailing;
  const _InfoCard({required this.icon, required this.label, required this.value, required this.color, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ])),
          if (trailing != null) trailing!,
        ]),
      );
}