import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/water_intake.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class WaterIntakeProvider with ChangeNotifier {
  List<WaterIntake> _waterIntakes = [];
  List<WaterBottle> _bottles = [];
  DateTime _selectedDate = DateTime.now();
  double _dailyWaterGoal = 2000; // em ml
  bool _notificationsEnabled = false;
  int _notificationInterval = 60; // em minutos

  List<WaterIntake> get waterIntakes => _waterIntakes;
  List<WaterBottle> get bottles => _bottles;
  DateTime get selectedDate => _selectedDate;
  double get dailyWaterGoal => _dailyWaterGoal;
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationInterval => _notificationInterval;

  // Calcula o total de água consumida no dia
  double get totalWaterIntake {
    return _waterIntakes.fold(0.0, (sum, intake) => sum + intake.amount);
  }

  // Calcula o progresso em relação à meta
  double get waterProgress => totalWaterIntake / _dailyWaterGoal;

  // Retorna os consumos de água de uma data específica
  List<WaterIntake> getIntakesByDate(DateTime date) {
    return _waterIntakes.where((intake) {
      return intake.date.year == date.year &&
             intake.date.month == date.month &&
             intake.date.day == date.day;
    }).toList();
  }

  // Carrega os consumos de água de uma data específica
  Future<void> loadWaterIntakesByDate(DateTime date) async {
    _selectedDate = date;
    _waterIntakes = await DatabaseHelper.instance.getWaterIntakesByDate(date);
    notifyListeners();
  }

  // Carrega os consumos de água de um período
  Future<void> loadWaterIntakesByDateRange(DateTime start, DateTime end) async {
    _waterIntakes = await DatabaseHelper.instance.getWaterIntakesByDateRange(start, end);
    notifyListeners();
  }

  // Calcula o total de água consumida em um período
  double getTotalWaterIntakeByDateRange(DateTime start, DateTime end) {
    return _waterIntakes
        .where((intake) => intake.date.isAfter(start.subtract(const Duration(days: 1))) && intake.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0.0, (sum, intake) => sum + intake.amount);
  }

  // Retorna o total de água consumida por dia da semana
  Map<int, double> getWeeklyWaterIntakes() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <int, double>{};
    
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayIntakes = _waterIntakes.where((intake) {
        return intake.date.year == day.year &&
               intake.date.month == day.month &&
               intake.date.day == day.day;
      }).toList();
      
      final total = dayIntakes.fold(0.0, (sum, intake) => sum + intake.amount);
      weeklyData[i] = total;
    }
    
    return weeklyData;
  }

  // Adiciona um novo consumo de água
  Future<void> addWaterIntake(WaterIntake intake) async {
    await DatabaseHelper.instance.createWaterIntake(intake);
    _waterIntakes.add(intake);
    notifyListeners();
  }

  // Remove um consumo de água
  Future<void> deleteWaterIntake(String intakeId) async {
    await DatabaseHelper.instance.deleteWaterIntake(intakeId);
    _waterIntakes.removeWhere((intake) => intake.id == intakeId);
    notifyListeners();
  }

  // Carrega todas as garrafas
  Future<void> loadBottles() async {
    _bottles = await DatabaseHelper.instance.getAllWaterBottles();
    notifyListeners();
  }

  // Adiciona uma nova garrafa
  Future<void> addBottle(WaterBottle bottle) async {
    await DatabaseHelper.instance.createWaterBottle(bottle);
    _bottles.add(bottle);
    notifyListeners();
  }

  // Atualiza uma garrafa existente
  Future<void> updateBottle(WaterBottle bottle) async {
    await DatabaseHelper.instance.updateWaterBottle(bottle);
    final index = _bottles.indexWhere((b) => b.id == bottle.id);
    if (index != -1) {
      _bottles[index] = bottle;
      notifyListeners();
    }
  }

  // Remove uma garrafa
  Future<void> deleteBottle(String bottleId) async {
    await DatabaseHelper.instance.deleteWaterBottle(bottleId);
    _bottles.removeWhere((bottle) => bottle.id == bottleId);
    notifyListeners();
  }

  // Define a meta diária de água
  void setDailyWaterGoal(double goal) {
    // Só atualiza se o valor for diferente
    if (_dailyWaterGoal == goal) {
      debugPrint('Meta diária de água já é $goal ml');
      return;
    }
    
    _dailyWaterGoal = goal;
    _saveDailyWaterGoal(goal);
    notifyListeners();
  }

  // Salva a meta diária de água no banco de dados
  Future<void> _saveDailyWaterGoal(double goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      // Verifica se já existe uma meta salva
      final existing = await db.query('settings', where: 'key = ?', whereArgs: ['daily_water_goal']);

      if (existing.isNotEmpty) {
        // Atualiza a meta existente
        await db.update(
          'settings',
          {'key': 'daily_water_goal', 'value': goal.toString()},
          where: 'key = ?',
          whereArgs: ['daily_water_goal'],
        );
      } else {
        // Insere nova meta
        await db.insert(
          'settings',
          {'key': 'daily_water_goal', 'value': goal.toString()},
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar meta diária de água: $e');
    }
  }

  // Carrega a meta diária de água do banco de dados
  Future<void> loadDailyWaterGoal() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['daily_water_goal'],
      );

      if (result.isNotEmpty) {
        final goal = double.parse(result.first['value'] as String);
        _dailyWaterGoal = goal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar meta diária de água: $e');
    }
  }

  // Define se as notificações estão habilitadas
  void setNotificationsEnabled(bool enabled) async {
    // Só atualiza se o valor for diferente
    if (_notificationsEnabled == enabled) {
      debugPrint('Notificações já estão ${enabled ? 'habilitadas' : 'desabilitadas'}');
      return;
    }
    
    _notificationsEnabled = enabled;
    _saveNotificationSettings();

    if (enabled) {
      // Agenda as notificações
      await NotificationService().initialize();
      await NotificationService().requestPermissions();
      await NotificationService().scheduleWaterReminder(
        intervalMinutes: _notificationInterval,
        title: '💧 Hora de beber água!',
        body: 'Não esqueça de se hidratar! Beba um copo de água agora.',
      );
      debugPrint('Notificações de água agendadas');
    } else {
      // Cancela as notificações
      await NotificationService().cancelWaterReminders();
      debugPrint('Notificações de água canceladas');
    }

    notifyListeners();
  }

  // Define o intervalo de notificações
  void setNotificationInterval(int minutes) async {
    // Só atualiza se o valor for diferente
    if (_notificationInterval == minutes) {
      debugPrint('Intervalo de notificação já é $minutes minutos');
      return;
    }
    
    _notificationInterval = minutes;
    _saveNotificationSettings();

    // Se as notificações estiverem habilitadas, reagenda com o novo intervalo
    if (_notificationsEnabled) {
      await NotificationService().cancelWaterReminders();
      await NotificationService().scheduleWaterReminder(
        intervalMinutes: _notificationInterval,
        title: '💧 Hora de beber água!',
        body: 'Não esqueça de se hidratar! Beba um copo de água agora.',
      );
      debugPrint('Notificações reagendadas com intervalo de $minutes minutos');
    }

    notifyListeners();
  }

  // Salva as configurações de notificação no banco de dados
  Future<void> _saveNotificationSettings() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Salva se as notificações estão habilitadas
      await db.insert(
        'settings',
        {'key': 'water_notifications_enabled', 'value': _notificationsEnabled.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Salva o intervalo de notificações
      await db.insert(
        'settings',
        {'key': 'water_notification_interval', 'value': _notificationInterval.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Erro ao salvar configurações de notificação: $e');
    }
  }

  // Carrega as configurações de notificação do banco de dados
  Future<void> loadNotificationSettings() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Carrega se as notificações estão habilitadas
      final enabledResult = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['water_notifications_enabled'],
      );
      if (enabledResult.isNotEmpty) {
        _notificationsEnabled = enabledResult.first['value'] == 'true';
      }

      // Carrega o intervalo de notificações
      final intervalResult = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['water_notification_interval'],
      );
      if (intervalResult.isNotEmpty) {
        _notificationInterval = int.parse(intervalResult.first['value'] as String);
      }

      // Só agenda notificações se estiverem habilitadas
      if (_notificationsEnabled) {
        await NotificationService().initialize();
        await NotificationService().scheduleWaterReminder(
          intervalMinutes: _notificationInterval,
          title: '💧 Hora de beber água!',
          body: 'Não esqueça de se hidratar! Beba um copo de água agora.',
        );
        debugPrint('Notificações de água restauradas');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configurações de notificação: $e');
    }
  }
}
