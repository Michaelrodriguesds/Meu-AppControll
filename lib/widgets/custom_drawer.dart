import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String nomeUsuario;
  final String emailUsuario;

  const CustomDrawer({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(nomeUsuario),
            accountEmail: Text(emailUsuario),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                nomeUsuario.isNotEmpty ? nomeUsuario[0] : '',
                style: const TextStyle(fontSize: 32, color: Colors.teal),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Projetos'),
            onTap: () => Navigator.pushReplacementNamed(context, '/projetos'),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Anotações'),
            onTap: () => Navigator.pushReplacementNamed(context, '/anotacoes'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => Navigator.pushReplacementNamed(context, '/perfil'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair da Conta', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
