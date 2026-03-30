import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';
import '../models/food_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE meals (id TEXT PRIMARY KEY, type INTEGER NOT NULL, date TEXT NOT NULL)');
    await db.execute('CREATE TABLE food_items (id TEXT PRIMARY KEY, meal_id TEXT NOT NULL, name TEXT NOT NULL, calories REAL NOT NULL, proteins REAL NOT NULL, lipids REAL NOT NULL, carbohydrates REAL NOT NULL, fibers REAL NOT NULL, quantity REAL NOT NULL, FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE food_base (id TEXT PRIMARY KEY, name TEXT NOT NULL, calories REAL NOT NULL, proteins REAL NOT NULL, lipids REAL NOT NULL, carbohydrates REAL NOT NULL, fibers REAL NOT NULL)');
  }

  Future<Meal> createMeal(Meal meal) async {
    final db = await instance.database;
    await db.insert('meals', {'id': meal.id, 'type': meal.type.index, 'date': meal.date.toIso8601String()});
    for (var item in meal.items) {
      await db.insert('food_items', {'id': item.id, 'meal_id': meal.id, 'name': item.name, 'calories': item.calories, 'proteins': item.proteins, 'lipids': item.lipids, 'carbohydrates': item.carbohydrates, 'fibers': item.fibers, 'quantity': item.quantity});
    }
    return meal;
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final mealMaps = await db.query('meals', where: 'date >= ? AND date < ?', whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
    List<Meal> meals = [];
    for (var mealMap in mealMaps) {
      final foodItemMaps = await db.query('food_items', where: 'meal_id = ?', whereArgs: [mealMap['id']]);
      final foodItems = foodItemMaps.map((map) => FoodItem.fromMap(map)).toList();
      meals.add(Meal(id: mealMap['id'] as String, type: MealType.values[mealMap['type'] as int], date: DateTime.parse(mealMap['date'] as String), items: foodItems));
    }
    return meals;
  }

  Future<List<Meal>> getMealsByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final mealMaps = await db.query('meals', where: 'date >= ? AND date <= ?', whereArgs: [start.toIso8601String(), end.toIso8601String()], orderBy: 'date DESC');
    List<Meal> meals = [];
    for (var mealMap in mealMaps) {
      final foodItemMaps = await db.query('food_items', where: 'meal_id = ?', whereArgs: [mealMap['id']]);
      final foodItems = foodItemMaps.map((map) => FoodItem.fromMap(map)).toList();
      meals.add(Meal(id: mealMap['id'] as String, type: MealType.values[mealMap['type'] as int], date: DateTime.parse(mealMap['date'] as String), items: foodItems));
    }
    return meals;
  }

  Future<int> deleteMeal(String id) async {
    final db = await instance.database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await instance.database;
    await db.delete('food_items', where: 'meal_id = ?', whereArgs: [meal.id]);
    for (var item in meal.items) {
      await db.insert('food_items', {'id': item.id, 'meal_id': meal.id, 'name': item.name, 'calories': item.calories, 'proteins': item.proteins, 'lipids': item.lipids, 'carbohydrates': item.carbohydrates, 'fibers': item.fibers, 'quantity': item.quantity});
    }
    return await db.update('meals', {'type': meal.type.index, 'date': meal.date.toIso8601String()}, where: 'id = ?', whereArgs: [meal.id]);
  }

  Future<FoodItem> createFoodBase(FoodItem food) async {
    final db = await instance.database;
    await db.insert('food_base', {'id': food.id, 'name': food.name, 'calories': food.calories, 'proteins': food.proteins, 'lipids': food.lipids, 'carbohydrates': food.carbohydrates, 'fibers': food.fibers});
    return food;
  }

  Future<List<FoodItem>> getAllFoodBase() async {
    final db = await instance.database;
    final maps = await db.query('food_base');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> searchFoodBase(String query) async {
    final db = await instance.database;
    final maps = await db.query('food_base', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}