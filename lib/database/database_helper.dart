import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../models/food_product.dart';

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
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE meals (id TEXT PRIMARY KEY, type INTEGER NOT NULL, date TEXT NOT NULL)');
    await db.execute('CREATE TABLE food_items (id TEXT PRIMARY KEY, meal_id TEXT NOT NULL, name TEXT NOT NULL, calories REAL NOT NULL, proteins REAL NOT NULL, lipids REAL NOT NULL, carbohydrates REAL NOT NULL, fibers REAL NOT NULL, quantity REAL NOT NULL, border_color INTEGER NOT NULL DEFAULT 4278190335, icon INTEGER, FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE food_base (id TEXT PRIMARY KEY, name TEXT NOT NULL, calories REAL NOT NULL, proteins REAL NOT NULL, lipids REAL NOT NULL, carbohydrates REAL NOT NULL, fibers REAL NOT NULL)');
    await db.execute('CREATE TABLE food_products (id TEXT PRIMARY KEY, name TEXT NOT NULL, brand TEXT, serving_size REAL NOT NULL, servings_per_package REAL, icon INTEGER NOT NULL DEFAULT 0, border_color INTEGER NOT NULL DEFAULT 4278190335, energy_kcal REAL NOT NULL, energy_kj REAL, carbohydrates REAL NOT NULL, total_sugars REAL NOT NULL, added_sugars REAL NOT NULL, proteins REAL NOT NULL, fat_total REAL NOT NULL, fat_saturated REAL NOT NULL, fat_trans REAL NOT NULL, fiber REAL NOT NULL, sodium REAL NOT NULL)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('CREATE TABLE food_products (id TEXT PRIMARY KEY, name TEXT NOT NULL, brand TEXT, serving_size REAL NOT NULL, servings_per_package REAL, icon INTEGER NOT NULL DEFAULT 0, border_color INTEGER NOT NULL DEFAULT 4278190335, energy_kcal REAL NOT NULL, energy_kj REAL, carbohydrates REAL NOT NULL, total_sugars REAL NOT NULL, added_sugars REAL NOT NULL, proteins REAL NOT NULL, fat_total REAL NOT NULL, fat_saturated REAL NOT NULL, fat_trans REAL NOT NULL, fiber REAL NOT NULL, sodium REAL NOT NULL)');
    }
    if (oldVersion < 3) {
      // Adiciona os campos icon e border_color à tabela existente
      await db.execute('ALTER TABLE food_products ADD COLUMN icon INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE food_products ADD COLUMN border_color INTEGER NOT NULL DEFAULT 4278190335');
    }
    if (oldVersion < 4) {
      // Adiciona o campo border_color à tabela food_items
      await db.execute('ALTER TABLE food_items ADD COLUMN border_color INTEGER NOT NULL DEFAULT 4278190335');
    }
    if (oldVersion < 5) {
      // Adiciona o campo icon à tabela food_items
      await db.execute('ALTER TABLE food_items ADD COLUMN icon INTEGER');
    }
  }

  Future<Meal> createMeal(Meal meal) async {
    final db = await instance.database;
    await db.insert('meals', {'id': meal.id, 'type': meal.type.index, 'date': meal.date.toIso8601String()});
    for (var item in meal.items) {
      await db.insert('food_items', {
        'id': item.id,
        'meal_id': meal.id,
        'name': item.name,
        'calories': item.calories,
        'proteins': item.proteins,
        'lipids': item.lipids,
        'carbohydrates': item.carbohydrates,
        'fibers': item.fibers,
        'quantity': item.quantity,
        'border_color': item.borderColor.value,
        'icon': item.icon?.index,
      });
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
      await db.insert('food_items', {'id': item.id, 'meal_id': meal.id, 'name': item.name, 'calories': item.calories, 'proteins': item.proteins, 'lipids': item.lipids, 'carbohydrates': item.carbohydrates, 'fibers': item.fibers, 'quantity': item.quantity, 'border_color': item.borderColor.value});
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

  // Métodos para FoodProduct
  Future<FoodProduct> createFoodProduct(FoodProduct product) async {
    final db = await instance.database;
    await db.insert('food_products', product.toMap());
    return product;
  }

  Future<List<FoodProduct>> getAllFoodProducts() async {
    final db = await instance.database;
    final maps = await db.query('food_products');
    return maps.map((map) => FoodProduct.fromMap(map)).toList();
  }

  Future<FoodProduct?> getFoodProductById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'food_products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FoodProduct.fromMap(maps.first);
  }

  Future<List<FoodProduct>> searchFoodProducts(String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'food_products',
      where: 'name LIKE ? OR brand LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => FoodProduct.fromMap(map)).toList();
  }

  Future<int> updateFoodProduct(FoodProduct product) async {
    final db = await instance.database;
    return await db.update(
      'food_products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteFoodProduct(String id) async {
    final db = await instance.database;
    return await db.delete(
      'food_products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}