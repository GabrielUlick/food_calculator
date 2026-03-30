
import 'food_item.dart';

enum MealType {
  breakfast('Café da Manhã'),
  lunch('Almoço'),
  dinner('Janta'),
  snack('Lanchinho');

  final String displayName;
  const MealType(this.displayName);
}

class Meal {
  final String id;
  final MealType type;
  final DateTime date;
  final List<FoodItem> items;

  Meal({
    required this.id,
    required this.type,
    required this.date,
    required this.items,
  });

  // Calcula o total de cada nutriente da refeição
  double get totalCalories => items.fold(0, (sum, item) => sum + item.adjustedCalories);
  double get totalProteins => items.fold(0, (sum, item) => sum + item.adjustedProteins);
  double get totalLipids => items.fold(0, (sum, item) => sum + item.adjustedLipids);
  double get totalCarbohydrates => items.fold(0, (sum, item) => sum + item.adjustedCarbohydrates);
  double get totalFibers => items.fold(0, (sum, item) => sum + item.adjustedFibers);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      type: MealType.values[map['type']],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => FoodItem.fromMap(item))
          .toList(),
    );
  }

  Meal copyWith({
    String? id,
    MealType? type,
    DateTime? date,
    List<FoodItem>? items,
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      items: items ?? this.items,
    );
  }
}
