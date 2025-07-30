import 'package:flutter/material.dart';
import 'package:meu_app_financas/screens/login_screen.dart';
import 'package:meu_app_financas/screens/cadastro_screen.dart';
import 'package:meu_app_financas/screens/home_screen.dart';
import 'package:meu_app_financas/screens/projetos_screen.dart';
import 'package:meu_app_financas/screens/anotacoes_screen.dart';
import 'package:meu_app_financas/screens/anotacao_form.dart';
import 'package:meu_app_financas/screens/projeto_form.dart';
import 'package:meu_app_financas/screens/projeto_detalhe.dart';
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/models/anotacao_model.dart';

// Importa a tela de perfil criada
import 'package:meu_app_financas/screens/perfil_screen.dart';

void main() {
  runApp(const MeuAppFinancas());
}

class MeuAppFinancas extends StatelessWidget {
  const MeuAppFinancas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Finanças',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // Rotas básicas
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) {
          // Recupera argumentos obrigatórios para abrir home
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          if (args == null || args['token'] == null || args['usuarioId'] == null) {
            return const Scaffold(
              body: Center(child: Text('Erro: Dados de login não encontrados')),
            );
          }

          return HomeScreen(
            token: args['token'],
            usuarioId: args['usuarioId'],
          );
        },
        // Nova rota adicionada para a tela de perfil do usuário
        '/perfil': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          if (args == null || args['token'] == null) {
            return const Scaffold(
              body: Center(child: Text('Erro: Token não fornecido para perfil')),
            );
          }
          // Passa token para autenticação na tela de perfil
          return PerfilScreen(token: args['token']);
        },
      },
      // Rotas dinâmicas para telas que recebem argumentos complexos
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/projetos':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ProjetosScreen(token: args['token']),
            );

          case '/projeto_form':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ProjetoForm(
                usuarioId: args['usuarioId'].toString(),
                token: args['token'].toString(),
                projeto: args['projeto'] as Projeto?,
              ),
            );

          case '/projeto_detalhe':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ProjetoDetalheScreen(
                projeto: args['projeto'] as Projeto,
                token: args['token'].toString(),
              ),
            );

          case '/anotacoes':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AnotacoesScreen(
                usuarioId: args['usuarioId'].toString(),
                token: args['token'].toString(),
              ),
            );

          case '/anotacao_form':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AnotacaoForm(
                usuarioId: args['usuarioId'].toString(),
                token: args['token'].toString(),
                anotacao: args['anotacao'] as Anotacao?,
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Rota não encontrada')),
                body: const Center(child: Text('Página não encontrada')),
              ),
            );
        }
      },
    );
  }
}
