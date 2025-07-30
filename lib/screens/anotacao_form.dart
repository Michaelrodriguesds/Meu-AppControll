import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';

class AnotacaoForm extends StatefulWidget {
  final String usuarioId;
  final String token;
  final Anotacao? anotacao;

  const AnotacaoForm({
    Key? key,
    required this.usuarioId,
    required this.token,
    this.anotacao,
  }) : super(key: key);

  @override
  State<AnotacaoForm> createState() => _AnotacaoFormState();
}

class _AnotacaoFormState extends State<AnotacaoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.anotacao?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.anotacao?.conteudo ?? '');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final anotacao = Anotacao(
      id: widget.anotacao?.id,
      titulo: _tituloController.text,
      conteudo: _conteudoController.text,
      data: DateTime.now(),
      usuarioId: widget.usuarioId,
    );

    try {
      if (widget.anotacao == null) {
        await AnotacaoService.criar(anotacao, widget.token);
      } else {
        await AnotacaoService.atualizar(anotacao, widget.token);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.anotacao != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Anotação' : 'Nova Anotação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Informe um título' : null,
              ),
              TextFormField(
                controller: _conteudoController,
                decoration: const InputDecoration(labelText: 'Conteúdo'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o conteúdo' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(isEdit ? 'Salvar Alterações' : 'Criar Anotação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
