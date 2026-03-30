import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../database/database_helper.dart';

class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<FoodItem> _foodBase = [];
  DateTime _selectedDate = DateTime.now();
  double _dailyCalorieGoal = 2000;

  List<Meal> get meals => _meals;
  List<FoodItem> get foodBase => _foodBase;
  DateTime get selectedDate => _selectedDate;
  double get dailyCalorieGoal => _dailyCalorieGoal;

  // Calcula totais do dia
  double get totalCalories => _meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get totalProteins => _meals.fold(0, (sum, meal) => sum + meal.totalProteins);
  double get totalLipids => _meals.fold(0, (sum, meal) => sum + meal.totalLipids);
  double get totalCarbohydrates => _meals.fold(0, (sum, meal) => sum + meal.totalCarbohydrates);
  double get totalFibers => _meals.fold(0, (sum, meal) => sum + meal.totalFibers);

  // Calcula progresso em relação à meta
  double get calorieProgress => totalCalories / _dailyCalorieGoal;

  // Retorna refeições por tipo
  List<Meal> getMealsByType(MealType type) {
    return _meals.where((meal) => meal.type == type).toList();
  }

  // Carrega refeições de uma data específica
  Future<void> loadMealsByDate(DateTime date) async {
    _selectedDate = date;
    _meals = await DatabaseHelper.instance.getMealsByDate(date);
    notifyListeners();
  }

  // Carrega refeições de um período
  Future<void> loadMealsByDateRange(DateTime start, DateTime end) async {
    _meals = await DatabaseHelper.instance.getMealsByDateRange(start, end);
    notifyListeners();
  }

  // Carrega base de alimentos
  Future<void> loadFoodBase() async {
    _foodBase = await DatabaseHelper.instance.getAllFoodBase();
    notifyListeners();
  }

  // Busca alimentos na base
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) {
      await loadFoodBase();
      return _foodBase;
    }
    return await DatabaseHelper.instance.searchFoodBase(query);
  }

  // Adiciona uma nova refeição
  Future<void> addMeal(Meal meal) async {
    await DatabaseHelper.instance.createMeal(meal);
    _meals.add(meal);
    notifyListeners();
  }

  // Atualiza uma refeição existente
  Future<void> updateMeal(Meal meal) async {
    await DatabaseHelper.instance.updateMeal(meal);
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
      notifyListeners();
    }
  }

  // Remove uma refeição
  Future<void> deleteMeal(String mealId) async {
    await DatabaseHelper.instance.deleteMeal(mealId);
    _meals.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  // Adiciona um alimento à base
  Future<void> addFoodToBase(FoodItem food) async {
    await DatabaseHelper.instance.createFoodBase(food);
    _foodBase.add(food);
    notifyListeners();
  }

  // Define a meta diária de calorias
  void setDailyCalorieGoal(double goal) {
    debugPrint('Definindo meta diária de calorias: $goal');
    _dailyCalorieGoal = goal;
    _saveDailyCalorieGoal(goal);
    notifyListeners();
  }

  // Salva a meta diária de calorias no banco de dados
  Future<void> _saveDailyCalorieGoal(double goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      // Verifica se já existe uma meta salva
      final existing = await db.query('settings', where: 'key = ?', whereArgs: ['daily_calorie_goal']);

      if (existing.isNotEmpty) {
        // Atualiza a meta existente
        await db.update(
          'settings',
          {'key': 'daily_calorie_goal', 'value': goal.toString()},
          where: 'key = ?',
          whereArgs: ['daily_calorie_goal'],
        );
      } else {
        // Insere nova meta
        await db.insert(
          'settings',
          {'key': 'daily_calorie_goal', 'value': goal.toString()},
        );
      }
      debugPrint('Meta diária de calorias salva no banco: $goal');
    } catch (e) {
      debugPrint('Erro ao salvar meta diária de calorias: $e');
    }
  }

  // Carrega a meta diária de calorias do banco de dados
  Future<void> loadDailyCalorieGoal() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['daily_calorie_goal'],
      );

      if (result.isNotEmpty) {
        final goal = double.parse(result.first['value'] as String);
        _dailyCalorieGoal = goal;
        debugPrint('Meta diária de calorias carregada do banco: $goal');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar meta diária de calorias: $e');
    }
  }

  // Muda a data selecionada
  void changeDate(DateTime date) {
    _selectedDate = date;
    loadMealsByDate(date);
  }

  // Retorna o total de calorias por dia da semana
  Map<int, double> getWeeklyCalories() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <int, double>{};
    
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayMeals = _meals.where((meal) {
        return meal.date.year == day.year &&
               meal.date.month == day.month &&
               meal.date.day == day.day;
      }).toList();
      
      final total = dayMeals.fold(0.0, (sum, meal) => sum + meal.totalCalories);
      weeklyData[i] = total;
    }
    
    return weeklyData;
  }
}