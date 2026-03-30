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
    _dailyCalorieGoal = goal;
    notifyListeners();
  }

  // Muda a data selecionada
  void changeDate(DateTime date) {
    _selectedDate = date;
    loadMealsByDate(date);
  }
}