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

  DateTime? _dataSelecionada; // Armazena a data escolhida para o lembrete

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.anotacao?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.anotacao?.conteudo ?? '');
    _dataSelecionada = widget.anotacao?.data; // Preenche se for edição
  }

  // Exibe o seletor de data
  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? agora,
      firstDate: agora.subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );

    if (selecionada != null) {
      setState(() => _dataSelecionada = selecionada);
    }
  }

  // Salva anotação (novo ou edição)
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final anotacao = Anotacao(
      id: widget.anotacao?.id,
      titulo: _tituloController.text,
      conteudo: _conteudoController.text,
      data: _dataSelecionada ?? DateTime.now(),
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
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.anotacao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Anotação' : 'Nova Anotação'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Campo Título
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Informe um título' : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Conteúdo
                  TextFormField(
                    controller: _conteudoController,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (v) => v == null || v.isEmpty ? 'Informe o conteúdo' : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Lembrete (Data)
                  ListTile(
                    onTap: _selecionarData,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Colors.teal),
                    title: const Text('Data do Lembrete'),
                    subtitle: Text(
                      _dataSelecionada != null
                          ? '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'
                          : 'Nenhuma data selecionada',
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                  ),
                  const SizedBox(height: 20),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? 'Salvar Alterações' : 'Criar Anotação'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
