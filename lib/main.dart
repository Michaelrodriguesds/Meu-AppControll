import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/projetos_screen.dart';
import 'screens/projeto_form.dart';
import 'screens/projeto_detalhe.dart';
import 'screens/deposito_screen.dart';
import 'screens/estatisticas_screen.dart';
import 'screens/anotacoes_screen.dart';
import 'screens/anotacao_form.dart';
import 'screens/perfil_screen.dart';
import 'screens/configuracoes_screen.dart';
import 'models/projeto_model.dart';
import 'models/anotacao_model.dart';
import 'services/auth_service.dart';
import 'utils/notificacao_service.dart';
import 'screens/esqueci_senha_screen.dart';
import 'screens/verificar_codigo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa notificações locais
  await NotificacaoService.init();

  // Verifica sessão salva — se token expirado, limpa e vai para login
  final session = await AuthService.getSavedSession();
  final validSession = session != null
      ? await AuthService.validateToken(session['token'] ?? '')
          ? session
          : null
      : null;

  if (validSession == null && session != null) {
    // Token expirado — limpa sessão para não logar automaticamente com token morto
    await AuthService.logout();
  }

  runApp(FinanceApp(initialSession: validSession));
}

class FinanceApp extends StatelessWidget {
  final Map<String, String>? initialSession;

  const FinanceApp({super.key, this.initialSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00897B),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          elevation: 0,
        ),
      ),

      initialRoute: initialSession != null ? '/home' : '/login',

      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {

          // ── Auth ──────────────────────────────────────────────────────────
          case '/login':
            return _fade(const LoginScreen());

          case '/cadastro':
            return _slide(const CadastroScreen());

          // ── Home ──────────────────────────────────────────────────────────
          case '/home':
            // args pode ser null quando vem do initialRoute (sessão salva)
            final homeToken = (args?['token']     as String?)
                           ?? initialSession?['token']
                           ?? '';
            final homeUser  = (args?['usuarioId'] as String?)
                           ?? initialSession?['userId']
                           ?? initialSession?['usuarioId']
                           ?? '';
            return _fade(HomeScreen(token: homeToken, usuarioId: homeUser));

          // ── Projetos ──────────────────────────────────────────────────────
          case '/projetos':
            return _slide(ProjetosScreen(
              token:     args!['token'],
              usuarioId: args['usuarioId'] ?? '',
            ));

          case '/novo-projeto':
            return _slide(ProjetoForm(
              token:     args!['token'],
              usuarioId: args['usuarioId'] ?? '',
              projeto:   args['projeto'] as Projeto?,
            ));

          case '/projeto-detalhe':
            return _slide(ProjetoDetalheScreen(
              token:   args!['token'],
              projeto: args['projeto'] as Projeto,
            ));

          // ── Depósito — sobe de baixo igual modal de banco ─────────────────
          case '/deposito':
            return _modal(DepositoScreen(
              token:   args!['token'],
              projeto: args['projeto'] as Projeto,
            ));

          // ── Estatísticas ──────────────────────────────────────────────────
          case '/estatisticas':
            return _slide(EstatisticasScreen(token: args!['token']));

          // ── Anotações ─────────────────────────────────────────────────────
          case '/anotacoes':
            return _slide(AnotacoesScreen(
              token:     args!['token'],
              usuarioId: args['usuarioId'] ?? '',
            ));

          case '/nova-anotacao':
            return _slide(AnotacaoForm(
              token:     args!['token'],
              usuarioId: args['usuarioId'] ?? '',
              anotacao:  args['anotacao'] as Anotacao?,
            ));

          // ── Perfil ────────────────────────────────────────────────────────
          case '/perfil':
            return _slide(PerfilScreen(
              token:     args!['token'],
              usuarioId: args['usuarioId'] ?? '',
            ));

          // ── Configurações ─────────────────────────────────────────────────
          case '/configuracoes':
            return _slide(ConfiguracoesScreen(
              token:  args!['token'],
              nome:   args['nome']  ?? '',
              email:  args['email'] ?? '',
              theme:  args['theme'] ?? 'light',
            ));

          // ── Recuperação de senha ──────────────────────────────────────
          case '/esqueci-senha':
            return _slide(const EsqueciSenhaScreen());

          case '/verificar-codigo':
            return _slide(VerificarCodigoScreen(
              email: (args?['email'] as String?) ?? '',
            ));

          default:
            return _fade(const LoginScreen());
        }
      },
    );
  }

  // ── Transições ─────────────────────────────────────────────────────────────

  /// Fade suave — Login e Home (telas raiz)
  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder:        (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  /// Slide lateral — navegação normal entre telas
  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder:        (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  /// Modal de baixo para cima — Depósito (igual app de banco)
  static PageRoute _modal(Widget page) => PageRouteBuilder(
        pageBuilder:        (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}