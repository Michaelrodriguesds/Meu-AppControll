import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart'; // Para formatação da data brasileira

import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';

class AnotacoesScreen extends StatefulWidget {
  final String usuarioId;
  final String token;

  const AnotacoesScreen({
    super.key,
    required this.usuarioId,
    required this.token,
  });

  @override
  State<AnotacoesScreen> createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends State<AnotacoesScreen> {
  late Future<List<Anotacao>> _future;
  bool _mostrarConteudo = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Inicializa fusos horários
    _inicializarNotificacoes();
    _carregar();
  }

  Future<void> _inicializarNotificacoes() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _carregar() {
    _future = AnotacaoService.listar(widget.token);
  }

  void _atualizarTela() {
    setState(() => _carregar());
  }

  /// Agenda notificações para lembretes futuros
  Future<void> _agendarNotificacoes(List<Anotacao> anotacoes) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    for (final a in anotacoes) {
      if (a.lembrete != null) {
        final data = a.lembrete; // lembrete já deve ser DateTime?
        if (data != null && data.isAfter(DateTime.now())) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            a.id.hashCode, // ID deve ser int, usamos hashCode da string
            'Lembrete: ${a.titulo ?? "Sem título"}',
            a.conteudo ?? '',
            tz.TZDateTime.from(data, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'canal_lembrete',
                'Lembretes',
                channelDescription: 'Notificações de lembretes',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            // REMOVIDO uiLocalNotificationDateInterpretation para Android
          );
        }
      }
    }
  }

  /// Exclui anotação após confirmação
  void _confirmarExclusao(Anotacao a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Anotação'),
        content: const Text('Deseja excluir esta anotação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AnotacaoService.deletar(a.id!, widget.token);
        if (!mounted) return;
        _atualizarTela();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anotação excluída com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  /// Mostra detalhes da anotação
  void _abrirDetalhes(Anotacao a) {
    final lembreteFormatado = a.lembrete != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(a.lembrete!)
        : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.titulo ?? 'Sem título'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.conteudo ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            if (lembreteFormatado != null)
              Row(
                children: [
                  const Icon(Icons.alarm, size: 20),
                  const SizedBox(width: 8),
                  Text('Lembrete: $lembreteFormatado'),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Fechar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _carregarEAgendar() async {
    _carregar();
    final anotacoes = await _future;
    await _agendarNotificacoes(anotacoes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Minhas Anotações"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: Icon(
              _mostrarConteudo ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(() => _mostrarConteudo = !_mostrarConteudo),
          ),
        ],
      ),
      body: FutureBuilder<List<Anotacao>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final anotacoes = snapshot.data ?? [];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _agendarNotificacoes(anotacoes);
          });

          if (anotacoes.isEmpty) {
            return const Center(child: Text('Nenhuma anotação encontrada.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _carregarEAgendar();
              _atualizarTela();
            },
            child: ListView.builder(
              itemCount: anotacoes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final a = anotacoes[index];
                final lembreteFormatado = a.lembrete != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(a.lembrete!)
                    : null;

                return GestureDetector(
                  onTap: () => _abrirDetalhes(a),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.titulo ?? 'Sem título',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'editar') {
                                    Navigator.pushNamed(
                                      context,
                                      '/anotacao_form',
                                      arguments: {
                                        'anotacao': a,
                                        'usuarioId': widget.usuarioId,
                                        'token': widget.token,
                                      },
                                    ).then((res) {
                                      if (res == true) _atualizarTela();
                                    });
                                  } else if (value == 'excluir') {
                                    _confirmarExclusao(a);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                                  PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _mostrarConteudo ? (a.conteudo ?? '') : '•••••••••••••••••••••',
                            style: TextStyle(
                              fontSize: 14,
                              color: _mostrarConteudo ? Colors.black87 : Colors.grey,
                              fontStyle: _mostrarConteudo ? FontStyle.normal : FontStyle.italic,
                            ),
                          ),
                          if (lembreteFormatado != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm, size: 18, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Text(lembreteFormatado, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Nova Anotação"),
        backgroundColor: Colors.teal,
        onPressed: () async {
          final resultado = await Navigator.pushNamed(
            context,
            '/anotacao_form',
            arguments: {
              'usuarioId': widget.usuarioId,
              'token': widget.token,
            },
          );

          if (resultado == true) {
            _atualizarTela();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anotação criada com sucesso!')),
            );
          }
        },
      ),
    );
  }
}
