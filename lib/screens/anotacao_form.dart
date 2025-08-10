import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';
import '../utils/network_checker.dart';
import '../utils/notificacao_service.dart';  // Import do serviço de notificações

/// Formulário para criar ou editar uma anotação.
/// Recebe o [usuarioId], [token] para autenticação e, opcionalmente, uma [anotacao] para edição.
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

  // Data da anotação (opcional)
  DateTime? _dataSelecionada;

  // Data e hora do lembrete (opcional)
  DateTime? _lembreteSelecionado;

  @override
  void initState() {
    super.initState();

    // Inicializa os controladores com os valores da anotação, se estiver no modo edição
    _tituloController = TextEditingController(text: widget.anotacao?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.anotacao?.conteudo ?? '');
    _dataSelecionada = widget.anotacao?.data;
    _lembreteSelecionado = widget.anotacao?.lembrete;
  }

  /// Método para selecionar a data da anotação via date picker
  Future<void> _selecionarData() async {
    final agora = DateTime.now();

    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? agora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selecionada != null) {
      setState(() => _dataSelecionada = selecionada);
    }
  }

  /// Método para selecionar o lembrete, que envolve data e hora
  Future<void> _selecionarLembrete() async {
    final agora = DateTime.now();

    // Seleciona a data primeiro
    final data = await showDatePicker(
      context: context,
      initialDate: _lembreteSelecionado ?? agora,
      firstDate: agora,
      lastDate: DateTime(2100),
    );

    if (data == null) return;

    // Em seguida, seleciona a hora
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_lembreteSelecionado ?? agora),
    );

    if (hora == null) return;

    // Combina data e hora em um único DateTime
    final lembreteCompleto = DateTime(
      data.year,
      data.month,
      data.day,
      hora.hour,
      hora.minute,
    );

    setState(() => _lembreteSelecionado = lembreteCompleto);
  }

  /// Método para salvar a anotação, criando ou atualizando via serviço
  Future<void> _salvar() async {
    // Verifica conexão de rede antes de tentar salvar
    final conectado = await NetworkChecker.isOnline();
    if (!conectado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem conexão com a internet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Valida o formulário
    if (!_formKey.currentState!.validate()) return;

    // Monta o objeto anotação para envio
    final anotacao = Anotacao(
      id: widget.anotacao?.id,
      titulo: _tituloController.text,
      conteudo: _conteudoController.text,
      data: _dataSelecionada,
      lembrete: _lembreteSelecionado,
      usuarioId: widget.usuarioId,
    );

    try {
      // Se é edição, atualiza, senão cria novo registro
      if (widget.anotacao == null) {
        await AnotacaoService.criar(anotacao, widget.token);
      } else {
        await AnotacaoService.atualizar(anotacao, widget.token);
      }

      // Se o lembrete está definido e está no futuro, agenda a notificação
      if (_lembreteSelecionado != null && _lembreteSelecionado!.isAfter(DateTime.now())) {
        await NotificacaoService.agendarNotificacao(
          'Lembrete: ${_tituloController.text}',
          _conteudoController.text,
          _lembreteSelecionado!,
        );
      }

      // Volta para a tela anterior sinalizando sucesso
      Navigator.pop(context, true);
    } catch (e) {
      // Mostra erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
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
                  // Campo título
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

                  // Campo conteúdo
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

                  // Seletor de data da anotação
                  ListTile(
                    onTap: _selecionarData,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_note, color: Colors.teal),
                    title: const Text('Data da Anotação'),
                    subtitle: Text(
                      _dataSelecionada != null
                          ? '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'
                          : 'Nenhuma data selecionada',
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                  ),

                  const SizedBox(height: 16),

                  // Seletor de lembrete (data e hora)
                  ListTile(
                    onTap: _selecionarLembrete,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alarm, color: Colors.deepOrange),
                    title: const Text('Lembrete (Opcional)'),
                    subtitle: Text(
                      _lembreteSelecionado != null
                          ? '${_lembreteSelecionado!.day}/${_lembreteSelecionado!.month}/${_lembreteSelecionado!.year} às '
                            '${_lembreteSelecionado!.hour.toString().padLeft(2, '0')}:' 
                            '${_lembreteSelecionado!.minute.toString().padLeft(2, '0')}'
                          : 'Nenhum lembrete agendado',
                    ),
                    trailing: const Icon(Icons.access_time),
                  ),

                  const SizedBox(height: 24),

                  // Botão salvar
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
