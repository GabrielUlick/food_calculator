
class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double proteins; // em gramas
  final double lipids; // em gramas
  final double carbohydrates; // em gramas
  final double fibers; // em gramas
  final double quantity; // quantidade em gramas

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.lipids,
    required this.carbohydrates,
    required this.fibers,
    required this.quantity,
  });

  // Calcula os valores baseados na quantidade informada
  double get adjustedCalories => (calories * quantity) / 100;
  double get adjustedProteins => (proteins * quantity) / 100;
  double get adjustedLipids => (lipids * quantity) / 100;
  double get adjustedCarbohydrates => (carbohydrates * quantity) / 100;
  double get adjustedFibers => (fibers * quantity) / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'lipids': lipids,
      'carbohydrates': carbohydrates,
      'fibers': fibers,
      'quantity': quantity,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      proteins: map['proteins'],
      lipids: map['lipids'],
      carbohydrates: map['carbohydrates'],
      fibers: map['fibers'],
      quantity: map['quantity'],
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? proteins,
    double? lipids,
    double? carbohydrates,
    double? fibers,
    double? quantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      lipids: lipids ?? this.lipids,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fibers: fibers ?? this.fibers,
      quantity: quantity ?? this.quantity,
    );
  }
}
