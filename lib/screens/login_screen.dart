import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/usuario_service.dart';
import '../utils/network_checker.dart'; // ✅ Importa verificador de internet

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool mostrarSenha = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarEmailSalvo(); // ✅ Carrega e-mail salvo no SharedPreferences
  }

  /// ✅ Recupera e preenche o e-mail salvo localmente
  Future<void> _carregarEmailSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email_salvo') ?? '';
    _usuarioController.text = emailSalvo;
  }

  /// ✅ Salva o e-mail após login bem-sucedido
  Future<void> _salvarEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_salvo', email);
  }

  /// ✅ Realiza login com tratamento de erros e conexão
  Future<void> _realizarLogin() async {
    final email = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    // ✅ Verifica conexão com a internet
    final online = await NetworkChecker.isOnline();
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem conexão com a internet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginData = await UsuarioService.loginComUsuario(email, senha);

      if (loginData != null) {
        final token = loginData['token'];
        final usuarioId = loginData['usuarioId'];

        await _salvarEmail(email); // ✅ Salva o e-mail localmente

        // ✅ Navega para tela principal
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {'token': token, 'usuarioId': usuarioId},
        );
      } else {
        // ✅ Erro de credenciais inválidas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário ou senha inválidos'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // ✅ Erro de rede ou inesperado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao realizar login. Verifique sua conexão.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF00875F); // Verde escuro

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              // ✅ Ícone do app
              Icon(Icons.account_balance_wallet_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 24),

              // ✅ Título
              Text(
                'Bem-vindo de volta!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ✅ Subtítulo
              Text(
                'Faça login para acessar seus projetos financeiros.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ✅ Campo de e-mail
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuário ou E-mail',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Campo de senha com toggle
              TextField(
                controller: _senhaController,
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      mostrarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Botão de login ou indicador de carregamento
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton.icon(
                      onPressed: _realizarLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // ✅ Botão de criação de conta
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                child: const Text('Criar nova conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
