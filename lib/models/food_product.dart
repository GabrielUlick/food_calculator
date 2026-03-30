
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum FoodIcon {
  grain('Grãos', Icons.grain),
  restaurant('Restaurante', Icons.restaurant),
  lunch_dining('Refeição', Icons.lunch_dining),
  dinner_dining('Jantar', Icons.dinner_dining),
  set_meal('Prato', Icons.set_meal),
  ramen_dining('Macarrão', Icons.ramen_dining),
  rice_bowl('Arroz', Icons.rice_bowl),
  egg('Ovo', Icons.egg),
  bakery('Padaria', Icons.bakery_dining),
  coffee('Café', Icons.coffee),
  local_cafe('Cafeteria', Icons.local_cafe),
  icecream('Sorvete', Icons.icecream),
  cookie('Biscoito', Icons.cookie),
  cake('Bolo', Icons.cake),
  fastfood('Fast Food', Icons.fastfood),
  pizza('Pizza', Icons.local_pizza),
  burger('Hambúrguer', Icons.lunch_dining),
  kebab_dining('Kebab', Icons.kebab_dining),
  soup_kitchen('Sopa', Icons.soup_kitchen),
  outdoor_grill('Churrasco', Icons.outdoor_grill),
  water_drop('Líquido', Icons.water_drop),
  local_drink('Bebida', Icons.local_drink),
  sports_bar('Bar', Icons.sports_bar),
  wine_bar('Bar de Vinho', Icons.wine_bar),
  tapas('Petiscos', Icons.tapas),
  salad('Salada', Icons.spa),
  eco('Vegetais', Icons.eco),
  emoji_food_beverage('Comida', Icons.emoji_food_beverage),
  breakfast_dining('Café da Manhã', Icons.breakfast_dining),
  no_meals('Sem categoria', Icons.no_meals);

  final String label;
  final IconData iconData;

  const FoodIcon(this.label, this.iconData);
}

class FoodProduct {
  final String id;
  final String name;
  final String? brand; // Marca do produto (opcional)
  final double servingSize; // Tamanho da porção em gramas
  final double? servingsPerPackage; // Porções por embalagem (opcional)
  final FoodIcon icon; // Ícone do alimento
  final Color borderColor; // Cor da borda

  // Informações nutricionais por porção
  final double energyKcal; // Valor energético em kcal
  final double? energyKj; // Valor energético em kJ (opcional)
  final double carbohydrates; // Carboidratos em gramas
  final double totalSugars; // Açúcares totais em gramas
  final double addedSugars; // Açúcares adicionados em gramas
  final double proteins; // Proteínas em gramas
  final double fatTotal; // Gorduras totais em gramas
  final double fatSaturated; // Gorduras saturadas em gramas
  final double fatTrans; // Gorduras trans em gramas
  final double fiber; // Fibras alimentares em gramas
  final double sodium; // Sódio em miligramas

  FoodProduct({
    String? id,
    required this.name,
    this.brand,
    required this.servingSize,
    this.servingsPerPackage,
    this.icon = FoodIcon.restaurant,
    this.borderColor = Colors.blue,
    required this.energyKcal,
    this.energyKj,
    required this.carbohydrates,
    required this.totalSugars,
    required this.addedSugars,
    required this.proteins,
    required this.fatTotal,
    required this.fatSaturated,
    required this.fatTrans,
    required this.fiber,
    required this.sodium,
  }) : id = id ?? const Uuid().v4();

  // Calcula os valores nutricionais baseados na quantidade informada
  Map<String, double> calculateNutrients(double quantity) {
    final ratio = quantity / servingSize;
    return {
      'energyKcal': energyKcal * ratio,
      'energyKj': (energyKj ?? energyKcal * 4.184) * ratio,
      'carbohydrates': carbohydrates * ratio,
      'totalSugars': totalSugars * ratio,
      'addedSugars': addedSugars * ratio,
      'proteins': proteins * ratio,
      'fatTotal': fatTotal * ratio,
      'fatSaturated': fatSaturated * ratio,
      'fatTrans': fatTrans * ratio,
      'fiber': fiber * ratio,
      'sodium': sodium * ratio,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'serving_size': servingSize,
      'servings_per_package': servingsPerPackage,
      'icon': icon.index,
      'border_color': borderColor.value,
      'energy_kcal': energyKcal,
      'energy_kj': energyKj,
      'carbohydrates': carbohydrates,
      'total_sugars': totalSugars,
      'added_sugars': addedSugars,
      'proteins': proteins,
      'fat_total': fatTotal,
      'fat_saturated': fatSaturated,
      'fat_trans': fatTrans,
      'fiber': fiber,
      'sodium': sodium,
    };
  }

  factory FoodProduct.fromMap(Map<String, dynamic> map) {
    return FoodProduct(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      servingSize: map['serving_size'],
      servingsPerPackage: map['servings_per_package'],
      icon: FoodIcon.values[map['icon'] ?? 0],
      borderColor: Color(map['border_color'] ?? Colors.blue.value),
      energyKcal: map['energy_kcal'],
      energyKj: map['energy_kj'],
      carbohydrates: map['carbohydrates'],
      totalSugars: map['total_sugars'],
      addedSugars: map['added_sugars'],
      proteins: map['proteins'],
      fatTotal: map['fat_total'],
      fatSaturated: map['fat_saturated'],
      fatTrans: map['fat_trans'],
      fiber: map['fiber'],
      sodium: map['sodium'],
    );
  }

  FoodProduct copyWith({
    String? id,
    String? name,
    String? brand,
    double? servingSize,
    double? servingsPerPackage,
    FoodIcon? icon,
    Color? borderColor,
    double? energyKcal,
    double? energyKj,
    double? carbohydrates,
    double? totalSugars,
    double? addedSugars,
    double? proteins,
    double? fatTotal,
    double? fatSaturated,
    double? fatTrans,
    double? fiber,
    double? sodium,
  }) {
    return FoodProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingSize: servingSize ?? this.servingSize,
      servingsPerPackage: servingsPerPackage ?? this.servingsPerPackage,
      icon: icon ?? this.icon,
      borderColor: borderColor ?? this.borderColor,
      energyKcal: energyKcal ?? this.energyKcal,
      energyKj: energyKj ?? this.energyKj,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      totalSugars: totalSugars ?? this.totalSugars,
      addedSugars: addedSugars ?? this.addedSugars,
      proteins: proteins ?? this.proteins,
      fatTotal: fatTotal ?? this.fatTotal,
      fatSaturated: fatSaturated ?? this.fatSaturated,
      fatTrans: fatTrans ?? this.fatTrans,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
    );
  }
}
