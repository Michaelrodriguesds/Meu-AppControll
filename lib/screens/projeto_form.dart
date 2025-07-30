import 'package:flutter/material.dart';
import '../models/projeto_model.dart';
import '../services/projeto_service.dart';

class ProjetoForm extends StatefulWidget {
  final String token;
  final String usuarioId;
  final Projeto? projeto;

  const ProjetoForm({
    Key? key,
    required this.token,
    required this.usuarioId,
    this.projeto,
  }) : super(key: key);

  @override
  State<ProjetoForm> createState() => _ProjetoFormState();
}

class _ProjetoFormState extends State<ProjetoForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _categoriaController;
  late TextEditingController _valorNecessarioController;
  late TextEditingController _valorAplicadoController;
  DateTime? _dataInicio;

  bool get isEdit => widget.projeto != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.projeto?.titulo ?? '');
    _descricaoController = TextEditingController(text: widget.projeto?.descricao ?? '');
    _categoriaController = TextEditingController(text: widget.projeto?.categoria ?? '');
    _valorNecessarioController = TextEditingController(
        text: widget.projeto?.valorNecessario.toString() ?? '');
    _valorAplicadoController = TextEditingController(
        text: widget.projeto?.valorAplicado.toString() ?? '');
    _dataInicio = widget.projeto?.dataInicio ?? DateTime.now();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vn = double.tryParse(_valorNecessarioController.text) ?? 0.0;
    final va = double.tryParse(_valorAplicadoController.text) ?? 0.0;
    final progresso = vn == 0 ? 0.0 : (va / vn) * 100.0;

    final projeto = Projeto(
      id: widget.projeto?.id,
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      categoria: _categoriaController.text,
      valorNecessario: vn,
      valorAplicado: va,
      dataInicio: _dataInicio!,
      usuarioId: widget.usuarioId,
      progresso: progresso,
    );

    try {
      if (isEdit) {
        await ProjetoService.atualizarProjeto(projeto, widget.token);
      } else {
        await ProjetoService.criarProjeto(projeto, widget.token);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataInicio!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _dataInicio = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Projeto' : 'Novo Projeto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a categoria' : null,
              ),
              TextFormField(
                controller: _valorNecessarioController,
                decoration: const InputDecoration(labelText: 'Valor necessário'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Valor inválido' : null,
              ),
              TextFormField(
                controller: _valorAplicadoController,
                decoration: const InputDecoration(labelText: 'Valor aplicado'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Valor inválido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Data de Início: '),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      '${_dataInicio!.day}/${_dataInicio!.month}/${_dataInicio!.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(isEdit ? 'Salvar Alterações' : 'Criar Projeto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
