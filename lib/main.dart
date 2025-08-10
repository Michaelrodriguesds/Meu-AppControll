import 'package:flutter/material.dart';



// Telas principais
import 'package:meu_app_financas/screens/login_screen.dart';
import 'package:meu_app_financas/screens/cadastro_screen.dart';
import 'package:meu_app_financas/screens/home_screen.dart';
import 'package:meu_app_financas/screens/projetos_screen.dart';
import 'package:meu_app_financas/screens/anotacoes_screen.dart';
import 'package:meu_app_financas/screens/anotacao_form.dart';
import 'package:meu_app_financas/screens/projeto_form.dart';
import 'package:meu_app_financas/screens/projeto_detalhe.dart';
import 'package:meu_app_financas/screens/perfil_screen.dart';

// Modelos
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/models/anotacao_model.dart';

// Notificações
import 'package:meu_app_financas/utils/notificacao_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

// Gerenciador de Sessão (💡 Você precisa ter o arquivo session_manager.dart criado em utils/)
import 'package:meu_app_financas/utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa timezones e notificações
  tz.initializeTimeZones();
  await NotificacaoService.init();

  runApp(const MeuAppFinancas());
}

class MeuAppFinancas extends StatefulWidget {
  const MeuAppFinancas({super.key});

  @override
  State<MeuAppFinancas> createState() => _MeuAppFinancasState();
}

class _MeuAppFinancasState extends State<MeuAppFinancas> {
  late final SessionManager _sessionManager;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Inicializa o SessionManager com a função de logout
    _sessionManager = SessionManager(onLogout: _handleLogout);
    _sessionManager.iniciarMonitoramento();
  }

  @override
  void dispose() {
    _sessionManager.pararMonitoramento();
    super.dispose();
  }

  // Função chamada quando a sessão expira
  void _handleLogout() {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    // Aqui você pode exibir uma notificação ou Snackbar também
    debugPrint("Usuário deslogado automaticamente.");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _sessionManager.registrarInteracao,
      onPanDown: (_) => _sessionManager.registrarInteracao(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Meu App Finanças',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/home': (context) {
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
          '/perfil': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null || args['token'] == null) {
              return const Scaffold(
                body: Center(child: Text('Erro: Token não fornecido para perfil')),
              );
            }
            return PerfilScreen(token: args['token']);
          },
        },
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
      ),
    );
  }
}

