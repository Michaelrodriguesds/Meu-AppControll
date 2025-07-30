import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String nomeUsuario;
  final String emailUsuario;

  const CustomDrawer({
    Key? key,
    required this.nomeUsuario,
    required this.emailUsuario,
  }) : super(key: key);

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
                style: TextStyle(fontSize: 32, color: Colors.blue),
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),

          ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Projetos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/projetos');
            },
          ),

          ListTile(
            leading: Icon(Icons.note),
            title: Text('Anotações'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/anotacoes');
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/perfil');
            },
          ),

          Spacer(),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sair da Conta', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Implementar logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
Scaffold(
  appBar: AppBar(title: Text('Minha Tela')),
  drawer: CustomDrawer(
    nomeUsuario: 'João da Silva', 
    emailUsuario: 'joao@email.com',
  ),
  body: ...,
);
