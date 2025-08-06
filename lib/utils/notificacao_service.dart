import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacaoService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Inicializa os dados de fuso horário
    tz.initializeTimeZones();

    // Configurações específicas para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Inicialização geral
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
  }

  static Future<void> agendarNotificacao(
      String titulo, String conteudo, DateTime horario) async {
    // Define o horário usando timezone
    final tz.TZDateTime dataAgendada = tz.TZDateTime.from(horario, tz.local);

    await _plugin.zonedSchedule(
      0, // ID da notificação
      titulo, // Título
      conteudo, // Corpo da notificação
      dataAgendada, // Data e hora com timezone
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_lembrete', // ID do canal
          'Lembretes', // Nome legível do canal
          channelDescription: 'Canal para lembretes agendados',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Novo padrão Android
      matchDateTimeComponents:
          DateTimeComponents.time, // Para notificações recorrentes no mesmo horário
    );
  }
}
