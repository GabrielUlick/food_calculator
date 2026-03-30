import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializa o timezone
    tz_data.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações de inicialização
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inicializa o plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('NotificationService inicializado');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notificação tocada: ${response.payload}');
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      debugPrint('Permissão de notificação Android: $granted');
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Permissão de notificação iOS: $granted');
    }
  }

  Future<void> scheduleWaterReminder({
    required int intervalMinutes,
    required String title,
    required String body,
  }) async {
    // Primeiro, cancela notificações anteriores para evitar duplicatas
    await cancelWaterReminders();
    
    // Agenda múltiplas notificações para o dia
    final now = tz.TZDateTime.now(tz.local);
    final notificationsPerDay = (24 * 60) ~/ intervalMinutes;
    
    for (int i = 0; i < notificationsPerDay; i++) {
      final scheduledTime = now.add(Duration(minutes: intervalMinutes * (i + 1)));
      
      await _notificationsPlugin.zonedSchedule(
        i, // ID único para cada notificação
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            'Lembretes de Água',
            channelDescription: 'Notificações para lembrar de beber água',
            importance: Importance.high,
            priority: Priority.high,
            ongoing: false,
            autoCancel: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    debugPrint('$notificationsPerDay notificações agendadas para cada $intervalMinutes minutos');
  }

  tz.TZDateTime _getNextNotificationTime(int intervalMinutes) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(Duration(minutes: intervalMinutes));

    // Se a hora agendada já passou, agenda para o próximo dia
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Todas as notificações canceladas');
  }

  Future<void> cancelWaterReminders() async {
    // Cancela todas as notificações de água (calcula o número máximo possível)
    final maxNotifications = (24 * 60) ~/ 15; // Assumindo intervalo mínimo de 15 minutos
    for (int i = 0; i < maxNotifications; i++) {
      await _notificationsPlugin.cancel(i);
    }
    debugPrint('Lembretes de água cancelados');
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'water_reminders',
        'Lembretes de Água',
        channelDescription: 'Notificações para lembrar de beber água',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );

    debugPrint('Notificação imediata exibida: $title');
  }
}
