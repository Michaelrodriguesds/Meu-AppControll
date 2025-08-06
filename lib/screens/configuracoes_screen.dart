import 'package:flutter/material.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final String nome;
  final String email;
  final String theme; // valor inicial: 'dark' ou 'light'
  final VoidCallback onLogout;

  const ConfiguracoesScreen({
    Key? key,
    required this.nome,
    required this.email,
    required this.theme,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late bool isDarkTheme;

  @override
  void initState() {
    super.initState();
    // Define tema com base na string recebida ('dark' ou 'light')
    isDarkTheme = widget.theme.toLowerCase() == 'dark';
  }

  /// Alterna o tema localmente (não persiste entre sessões)
  void _alternarTema() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema ${isDarkTheme ? 'Escuro' : 'Claro'} ativado localmente'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Monta a interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // 🧾 Informações básicas
          _infoTile('👤 Nome', widget.nome),
          _infoTile('📧 Email', widget.email),
          _infoTile('🎨 Tema atual', isDarkTheme ? 'Escuro' : 'Claro'),

          const SizedBox(height: 30),

          // 🌙 Alternar tema
          ListTile(
            leading: Icon(Icons.brightness_6_rounded, color: Colors.teal.shade800),
            title: const Text('Alternar Tema'),
            subtitle: const Text('Muda entre claro e escuro (apenas local)'),
            trailing: Switch(
              value: isDarkTheme,
              onChanged: (_) => _alternarTema(),
              activeColor: Colors.teal,
            ),
          ),

          const SizedBox(height: 20),

          // 🚪 Botão sair
          ElevatedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para exibir um bloco de informação
  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Divider(height: 24),
      ],
    );
  }
}
