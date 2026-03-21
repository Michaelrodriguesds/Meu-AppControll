import 'package:flutter/material.dart';

// ✅ CORRIGIDO: construtor atualizado para receber apenas token + dados opcionais.
//    Antes recebia (nome, email, theme, onLogout) — incompatível com o sistema de rotas.
class ConfiguracoesScreen extends StatefulWidget {
  final String token;
  final String nome;    // passado via args da rota
  final String email;   // passado via args da rota
  final String theme;   // passado via args da rota

  const ConfiguracoesScreen({
    super.key,
    required this.token,
    this.nome  = '',
    this.email = '',
    this.theme = 'light',
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late bool isDarkTheme;
  static const _teal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    isDarkTheme = widget.theme.toLowerCase() == 'dark';
  }

  void _alternarTema() {
    setState(() => isDarkTheme = !isDarkTheme);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Tema ${isDarkTheme ? "Escuro" : "Claro"} ativado'),
      backgroundColor: _teal,
      duration: const Duration(seconds: 2),
    ));
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
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
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: const Text('Configurações', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Informações do usuário ────────────────────────────────────────
          _Section(title: 'Conta', children: [
            _InfoTile(label: 'Nome',  value: widget.nome.isNotEmpty  ? widget.nome  : '—', icon: Icons.person_rounded),
            _InfoTile(label: 'Email', value: widget.email.isNotEmpty ? widget.email : '—', icon: Icons.email_rounded),
            _InfoTile(label: 'Tema',  value: isDarkTheme ? 'Escuro' : 'Claro',             icon: Icons.color_lens_rounded),
          ]),
          const SizedBox(height: 20),

          // ── Preferências ──────────────────────────────────────────────────
          _Section(title: 'Preferências', children: [
            ListTile(
              leading: const Icon(Icons.brightness_6_rounded, color: _teal),
              title: const Text('Tema do app', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(isDarkTheme ? 'Escuro' : 'Claro'),
              trailing: Switch(value: isDarkTheme, onChanged: (_) => _alternarTema(), activeThumbColor: _teal),
            ),
          ]),
          const SizedBox(height: 28),

          // ── Logout ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _confirmarLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair da conta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.grey, letterSpacing: .8)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: const Color(0xFF00897B), size: 20),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      );
}