import 'dart:async';
import 'package:flutter/foundation.dart';

/// Gerencia a sessão do usuário com base em tempo total logado e inatividade.
class SessionManager {
  /// Tempo total de sessão: 10 minutos
  static const Duration _tempoSessao = Duration(minutes: 10);

  /// Tempo de inatividade permitido: 5 minutos
  static const Duration _tempoInatividade = Duration(minutes: 5);

  /// Callback chamado quando a sessão expira
  final VoidCallback onLogout;

  /// Timer para controlar o tempo total de sessão
  Timer? _timerSessao;

  /// Timer para controlar a inatividade
  Timer? _timerInatividade;

  SessionManager({required this.onLogout});

  /// Inicia os timers
  void iniciarMonitoramento() {
    _iniciarTimerSessao();
    _iniciarTimerInatividade();
  }

  /// Reseta o timer de inatividade a cada interação do usuário
  void registrarInteracao() {
    _timerInatividade?.cancel();
    _iniciarTimerInatividade();
  }

  /// Inicia o timer da sessão (duração total permitida)
  void _iniciarTimerSessao() {
    _timerSessao = Timer(_tempoSessao, _logout);
  }

  /// Inicia o timer de inatividade
  void _iniciarTimerInatividade() {
    _timerInatividade = Timer(_tempoInatividade, _logout);
  }

  /// Encerra todos os timers
  void pararMonitoramento() {
    _timerSessao?.cancel();
    _timerInatividade?.cancel();
  }

  /// Executa o logout automático
  void _logout() {
    pararMonitoramento();
    onLogout();
  }
}
