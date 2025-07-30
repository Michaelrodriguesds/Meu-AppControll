import 'package:flutter/material.dart';
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

  Future<void> _realizarLogin() async {
    setState(() => _isLoading = true);

    final email = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    final loginData = await UsuarioService.loginComUsuario(email, senha);

    setState(() => _isLoading = false);

    if (loginData != null) {
      final token = loginData['token'];
      final usuarioId = loginData['usuarioId'];

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'token': token, 'usuarioId': usuarioId},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login inválido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const FlutterLogo(size: 100),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para acessar seus projetos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usuarioController,
                decoration:
                    const InputDecoration(labelText: 'Usuário ou E-mail'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                        mostrarSenha ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => mostrarSenha = !mostrarSenha),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _realizarLogin,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                child: const Text('Criar nova conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
