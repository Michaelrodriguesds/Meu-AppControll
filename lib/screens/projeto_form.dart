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

  // Controladores dos campos
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

    // Inicializa os controladores com os valores do projeto (se for edição)
    _tituloController = TextEditingController(text: widget.projeto?.titulo ?? '');
    _descricaoController = TextEditingController(text: widget.projeto?.descricao ?? '');
    _categoriaController = TextEditingController(text: widget.projeto?.categoria ?? '');
    _valorNecessarioController = TextEditingController(
        text: widget.projeto?.valorNecessario.toString() ?? '');
    _valorAplicadoController = TextEditingController(
        text: widget.projeto?.valorAplicado.toString() ?? '');
    _dataInicio = widget.projeto?.dataInicio ?? DateTime.now();
  }

  /// Abre o seletor de data
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

  /// Valida e envia os dados para o backend
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

  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Projeto' : 'Novo Projeto'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo: Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
              ),

              const SizedBox(height: 12),

              // Campo: Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
              ),

              const SizedBox(height: 12),

              // Campo: Categoria
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe a categoria' : null,
              ),

              const SizedBox(height: 12),

              // Campo: Valor necessário
              TextFormField(
                controller: _valorNecessarioController,
                decoration: const InputDecoration(
                  labelText: 'Valor necessário',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Informe um valor válido'
                    : null,
              ),

              const SizedBox(height: 12),

              // Campo: Valor aplicado
              TextFormField(
                controller: _valorAplicadoController,
                decoration: const InputDecoration(
                  labelText: 'Valor aplicado',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Informe um valor válido'
                    : null,
              ),

              const SizedBox(height: 16),

              // Campo: Data de início
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  const Text('Data de Início:'),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      '${_dataInicio!.day}/${_dataInicio!.month}/${_dataInicio!.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botão: Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Salvar Alterações' : 'Criar Projeto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
