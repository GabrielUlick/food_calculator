import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../database/database_helper.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _userProfile != null;

  // Carrega o perfil do usuário do banco de dados
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Carregando perfil do usuário...');
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('user_profile', limit: 1);
      debugPrint('Encontrados ${maps.length} perfis no banco de dados');

      if (maps.isNotEmpty) {
        debugPrint('Dados do perfil: ${maps.first}');
        _userProfile = UserProfile.fromMap(maps.first);
        debugPrint('Perfil carregado com sucesso: ${_userProfile?.toMap()}');
      } else {
        debugPrint('Nenhum perfil encontrado no banco de dados');
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Salva o perfil do usuário no banco de dados
  Future<void> saveUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Salvando perfil do usuário...');
      debugPrint('Dados do perfil a ser salvo: ${profile.toMap()}');
      final db = await DatabaseHelper.instance.database;

      // Remove o perfil anterior se existir
      final deletedCount = await db.delete('user_profile');
      debugPrint('Perfis removidos: $deletedCount');

      // Insere o novo perfil
      final id = await db.insert('user_profile', profile.toMap());
      debugPrint('Perfil salvo com ID: $id');

      _userProfile = profile;
      debugPrint('Perfil definido no provider: ${_userProfile?.toMap()}');
    } catch (e) {
      debugPrint('Erro ao salvar perfil do usuário: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calcula a meta diária de calorias baseada no objetivo de peso
  double calculateDailyCalorieGoal({
    required double height,
    required double currentWeight,
    required int age,
    required String gender,
    required WeightGoal weightGoal,
    required DateTime targetDate,
    double? targetWeight,
  }) {
    // Calcula a taxa metabólica basal (TMB) usando a fórmula de Mifflin-St Jeor
    double tmb;
    if (gender.toLowerCase() == 'masculino') {
      tmb = 10 * currentWeight + 6.25 * height - 5 * age + 5;
    } else {
      tmb = 10 * currentWeight + 6.25 * height - 5 * age - 161;
    }

    // Multiplica pelo fator de atividade (assumindo moderado = 1.375)
    final tdee = tmb * 1.375;

    // Calcula o déficit ou superávit calórico necessário
    if (weightGoal == WeightGoal.maintain) {
      return tdee;
    }

    if (targetWeight == null) return tdee;

    final weightDifference = targetWeight - currentWeight;
    final daysUntilTarget = targetDate.difference(DateTime.now()).inDays;

    if (daysUntilTarget <= 0) return tdee;

    // 1 kg de gordura ≈ 7700 kcal
    final caloriesPerDay = (weightDifference * 7700) / daysUntilTarget;

    // Limita o déficit/superávit a 1000 kcal por dia (máximo seguro)
    final adjustedCalories = caloriesPerDay.clamp(-1000.0, 1000.0);

    return tdee + adjustedCalories;
  }

  // Retorna a data sugerida para atingir a meta de peso
  DateTime getSuggestedTargetDate({
    required double currentWeight,
    required double targetWeight,
    required WeightGoal weightGoal,
  }) {
    if (weightGoal == WeightGoal.maintain) {
      return DateTime.now().add(const Duration(days: 30));
    }

    final weightDifference = (targetWeight - currentWeight).abs();
    // Sugerir uma taxa de 0.5 kg por semana (máximo seguro)
    final weeksNeeded = weightDifference / 0.5;
    final daysNeeded = (weeksNeeded * 7).round();

    return DateTime.now().add(Duration(days: daysNeeded));
  }

  // Exclui o perfil do usuário do banco de dados
  Future<void> deleteUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('user_profile');
      _userProfile = null;
    } catch (e) {
      debugPrint('Erro ao excluir perfil do usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
