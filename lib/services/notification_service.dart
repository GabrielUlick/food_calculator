import 'dart:math';
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

  // Lista de mensagens amigáveis para as notificações de água
  static const List<String> _waterReminderTitles = [
    '💧 Hora de se hidratar!',
    '🚰 Beba um copo de água!',
    '💦 Sua saúde agradece!',
    '🌊 Água é vida!',
    '🥤 Hora de beber água!',
  ];

  static const List<String> _waterReminderBodies = [
    'Não esqueça de beber água! Seu corpo precisa se manter hidratado.',
    'Um copo de água agora faz toda a diferença para sua saúde!',
    'A hidratação é essencial para o bom funcionamento do seu corpo.',
    'Mantenha-se hidratado! Beba água regularmente ao longo do dia.',
    'Chegou a hora de beber água! Cuide da sua saúde.',
    'A água ajuda a manter sua energia e concentração. Beba agora!',
    'Pequenas pausas para beber água fazem muita diferença!',
  ];

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService já inicializado');
      return;
    }

    try {
      // Inicializa o timezone
      tz_data.initializeTimeZones();

      // Configurações para Android com canal de notificação
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
      debugPrint('✅ NotificationService inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar NotificationService: $e');
      rethrow;
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notificação tocada: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    bool granted = false;

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? androidGranted = await androidImplementation.requestNotificationsPermission();
        granted = androidGranted ?? false;
        debugPrint('📱 Permissão de notificação Android: $granted');
      }

      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? iosGranted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = granted || (iosGranted ?? false);
        debugPrint('🍎 Permissão de notificação iOS: $iosGranted');
      }
    } catch (e) {
      debugPrint('❌ Erro ao solicitar permissões: $e');
    }

    return granted;
  }

  Future<void> scheduleWaterReminder({
    required int intervalMinutes,
    String? customTitle,
    String? customBody,
  }) async {
    try {
      // Verifica se o serviço está inicializado
      if (!_initialized) {
        await initialize();
      }

      // Verifica permissões
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        debugPrint('⚠️ Permissões de notificação não concedidas');
        return;
      }

      // Primeiro, cancela notificações anteriores para evitar duplicatas
      await cancelWaterReminders();

      // Agenda múltiplas notificações para o dia
      final now = tz.TZDateTime.now(tz.local);
      final notificationsPerDay = min((24 * 60) ~/ intervalMinutes, 50); // Limita a 50 notificações

      for (int i = 0; i < notificationsPerDay; i++) {
        final scheduledTime = now.add(Duration(minutes: intervalMinutes * (i + 1)));

        // Seleciona mensagens aleatórias para cada notificação
        final title = customTitle ?? _getRandomTitle();
        final body = customBody ?? _getRandomBody();

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
              showWhen: true,
              icon: '@mipmap/ic_launcher',
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                '',
                htmlFormatBigText: true,
                contentTitle: '',
                htmlFormatContentTitle: true,
              ),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
            ),
          ),
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      debugPrint('✅ $notificationsPerDay notificações agendadas para cada $intervalMinutes minutos');
    } catch (e) {
      debugPrint('❌ Erro ao agendar notificações de água: $e');
      rethrow;
    }
  }

  String _getRandomTitle() {
    final random = Random();
    return _waterReminderTitles[random.nextInt(_waterReminderTitles.length)];
  }

  String _getRandomBody() {
    final random = Random();
    return _waterReminderBodies[random.nextInt(_waterReminderBodies.length)];
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
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('✅ Todas as notificações canceladas');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar notificações: $e');
    }
  }

  Future<void> cancelWaterReminders() async {
    try {
      // Cancela todas as notificações de água (calcula o número máximo possível)
      final maxNotifications = (24 * 60) ~/ 15; // Assumindo intervalo mínimo de 15 minutos
      for (int i = 0; i < maxNotifications; i++) {
        await _notificationsPlugin.cancel(i);
      }
      debugPrint('✅ Lembretes de água cancelados');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar lembretes de água: $e');
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Lembretes de Água',
          channelDescription: 'Notificações para lembrar de beber água',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );

      debugPrint('✅ Notificação imediata exibida: $title');
    } catch (e) {
      debugPrint('❌ Erro ao exibir notificação imediata: $e');
    }
  }
}
