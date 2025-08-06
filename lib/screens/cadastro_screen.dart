import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/usuario_service.dart';
import '../utils/form_validators.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _isLoading = false;
  bool _mostrarSenha = false;

  // Função para enviar dados ao backend
  Future<void> _cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final usuario = {
      'nome': nomeController.text.trim(),
      'email': emailController.text.trim(),
      'senha': senhaController.text.trim(),
    };

    final sucesso = await UsuarioService.criarUsuario(usuario);

    setState(() => _isLoading = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário criado com sucesso!')),
      );
      Navigator.pop(context); // Retorna à tela de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar usuário')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Cabeçalho com mensagem
              Text(
                'Vamos começar!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os campos abaixo para criar sua conta.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo Nome
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: FormValidators.naoVazio,
              ),
              const SizedBox(height: 16),

              // Campo Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: FormValidators.email,
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                controller: senhaController,
                obscureText: !_mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _mostrarSenha = !_mostrarSenha);
                    },
                  ),
                ),
                validator: FormValidators.senhaMinima,
              ),
              const SizedBox(height: 24),

              // Botão de envio
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _cadastrarUsuario,
                        icon: const Icon(Icons.check),
                        label: const Text('Criar Conta'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
