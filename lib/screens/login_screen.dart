import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/usuario_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool mostrarSenha = false;
  bool _isLoading = false;

  // Função de login com feedback visual
  Future<void> _realizarLogin() async {
    setState(() => _isLoading = true);

    final email = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    final loginData = await UsuarioService.loginComUsuario(email, senha);

    setState(() => _isLoading = false);

    if (loginData != null) {
      final token = loginData['token'];
      final usuarioId = loginData['usuarioId'];

      // Navega para tela principal com os dados do login
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'token': token, 'usuarioId': usuarioId},
      );
    } else {
      // Exibe erro se login falhar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou senha inválidos'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF00875F); // Verde escuro para finanças

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              // Logo customizada (substitua por sua imagem local se quiser)
              Icon(Icons.account_balance_wallet_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 24),

              // Título estilizado
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

              Text(
                'Faça login para acessar seus projetos financeiros.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo de usuário
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuário ou E-mail',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de senha com alternador de visibilidade
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

              // Botão de login ou indicador de carregamento
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

              // Botão de cadastro
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
