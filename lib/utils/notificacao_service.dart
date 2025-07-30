// utils/notificacao_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacaoService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
  }

  static Future<void> agendarNotificacao(String titulo, String conteudo, DateTime horario) async {
    await _plugin.zonedSchedule(
      0,
      titulo,
      conteudo,
      tz.TZDateTime.from(horario, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_lembrete',
          'Lembretes',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
