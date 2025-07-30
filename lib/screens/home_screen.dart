import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String token;
  final String usuarioId;

  const HomeScreen({
    Key? key,
    required this.token,
    required this.usuarioId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definindo um tema local para usar cores consistentes
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Bem-vindo(a)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined),
          tooltip: 'Sair',
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          splashRadius: 24,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.teal.shade900,
              child: Text(
                usuarioId.isNotEmpty ? usuarioId[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Header com texto + background moderno
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade800.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              'O que você deseja adicionar?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.6,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Cards com ações principais
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _ActionCard(
                  icon: Icons.add_circle_rounded,
                  title: 'Adicionar Novo Projeto',
                  subtitle: 'Crie um projeto com metas financeiras.',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/projeto_form',
                    arguments: {'usuarioId': usuarioId, 'token': token},
                  ),
                ),
                const SizedBox(height: 22),
                _ActionCard(
                  icon: Icons.note_add_rounded,
                  title: 'Adicionar Anotação Importante',
                  subtitle: 'Salve algo relevante em texto ou lembrete em data.',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/anotacao_form',
                    arguments: {'usuarioId': usuarioId, 'token': token},
                  ),
                ),
                const SizedBox(height: 36),
                const Divider(height: 1.5),
                const SizedBox(height: 20),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary),
                  title: const Text('📂 Ver Projetos', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/projetos',
                    arguments: {'token': token},
                  ),
                  horizontalTitleGap: 0,
                  minVerticalPadding: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.teal.shade50,
                  hoverColor: Colors.teal.shade100,
                ),

                const SizedBox(height: 14),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.note_rounded, color: theme.colorScheme.primary),
                  title: const Text('🗒️ Ver Anotações', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/anotacoes',
                    arguments: {'usuarioId': usuarioId, 'token': token},
                  ),
                  horizontalTitleGap: 0,
                  minVerticalPadding: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.teal.shade50,
                  hoverColor: Colors.teal.shade100,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shadowColor: Colors.teal.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.teal.withOpacity(0.2),
        highlightColor: Colors.teal.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 36, color: Colors.teal.shade700),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
