import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificacaoService {
  // Instância única do plugin de notificações locais
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Inicializa o serviço de notificações, incluindo permissões e timezones
  static Future<void> init() async {
    // Inicializa os dados de timezones para agendamento correto
    tz.initializeTimeZones();

    // Configuração específica para Android (ícone padrão)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração específica para iOS
    const iosSettings = DarwinInitializationSettings();

    // Configuração geral que agrupa Android e iOS
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializa o plugin com as configurações definidas
    await _plugin.initialize(initSettings);

    // Solicita permissão para notificações (se ainda não concedida)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Solicita permissões específicas para iOS (alertas, badge, som)
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Solicita permissão para alarmes exatos no Android (Android 12+)
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // Agenda uma notificação para um horário futuro definido
  static Future<void> agendarNotificacao(
  String titulo,
  String conteudo,
  DateTime horario,
) async {
  if (horario.isBefore(DateTime.now())) {
    throw Exception('Não é possível agendar no passado.');
  }

  final dataAgendada = tz.TZDateTime.from(horario, tz.local);

  const detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      'canal_lembrete_v2',
      'Lembretes',
      channelDescription: 'Canal para lembretes agendados',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await _plugin.zonedSchedule(
    id,
    titulo,
    conteudo,
    dataAgendada,
    detalhes,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}


  // Método para mostrar uma notificação de teste instantaneamente
  static Future<void> mostrarNotificacaoTeste() async {
    const detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_teste',
        'Teste',
        channelDescription: 'Canal para notificações de teste',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // Exibe a notificação imediatamente com ID fixo
    await _plugin.show(
      9999,
      'Teste de Notificação',
      'Se você está vendo isso, notificações estão funcionando!',
      detalhes,
    );
  }
}
