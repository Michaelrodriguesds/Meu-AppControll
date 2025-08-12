import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificacaoService {
  // Instância única do plugin de notificações locais
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Flag para garantir inicialização única
  static bool _inicializado = false;

  /// Inicializa o serviço de notificações:
  /// - Configura timezone
  /// - Inicializa o plugin com configurações para Android e iOS
  /// - Solicita permissões necessárias
  static Future<void> init() async {
    if (_inicializado) return; // evita múltiplas inicializações

    // Inicializa dados de timezone para agendamento correto
    tz.initializeTimeZones();

    // Configuração Android: ícone padrão
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração iOS
    const iosSettings = DarwinInitializationSettings();

    // Configuração geral
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    // Inicializa o plugin de notificações locais
    await _plugin.initialize(initSettings);

    // Solicita permissão de notificações no dispositivo (se negado, pede novamente)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Solicita permissões específicas para iOS (alertas, badge, som)
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Solicita permissão para alarmes exatos no Android 12+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _inicializado = true;
  }

  /// Agenda uma notificação para o horário futuro definido.
  /// Lança exceção se tentar agendar no passado ou se serviço não inicializado.
  static Future<void> agendarNotificacao(String titulo, String conteudo, DateTime horario) async {
    if (!_inicializado) {
      throw Exception('NotificacaoService não inicializado. Chame init() antes.');
    }

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

    // Gera um ID único baseado no timestamp atual em segundos
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Agendamento da notificação corrigido para a nova assinatura da função zonedSchedule
    await _plugin.zonedSchedule(
      id,
      titulo,
      conteudo,
      dataAgendada,
      detalhes,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // para agendamento único, sem repetição
    );
  }

  /// Exibe uma notificação instantânea de teste para verificar se o serviço está funcionando.
  static Future<void> mostrarNotificacaoTeste() async {
    if (!_inicializado) {
      throw Exception('NotificacaoService não inicializado. Chame init() antes.');
    }

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

    await _plugin.show(
      9999,
      'Teste de Notificação',
      'Se você está vendo isso, notificações estão funcionando!',
      detalhes,
    );
  }
}
