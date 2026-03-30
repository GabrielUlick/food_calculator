
import 'package:flutter/material.dart';
import 'food_product.dart';

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double proteins; // em gramas
  final double lipids; // em gramas
  final double carbohydrates; // em gramas
  final double fibers; // em gramas
  final double quantity; // quantidade em gramas
  final Color borderColor; // cor da borda
  final FoodIcon? icon; // ícone do alimento

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.lipids,
    required this.carbohydrates,
    required this.fibers,
    required this.quantity,
    this.borderColor = Colors.blue,
    this.icon,
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
      'borderColor': borderColor.value,
      'icon': icon?.index,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    final colorValue = map['borderColor'] ?? Colors.blue.value;
    final color = Color(colorValue);

    // Recupera o ícone se existir
    FoodIcon? icon;
    if (map['icon'] != null) {
      icon = FoodIcon.values[map['icon'] as int];
    }

    return FoodItem(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      proteins: map['proteins'],
      lipids: map['lipids'],
      carbohydrates: map['carbohydrates'],
      fibers: map['fibers'],
      quantity: map['quantity'],
      borderColor: color,
      icon: icon,
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
    Color? borderColor,
    FoodIcon? icon,
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
      borderColor: borderColor ?? this.borderColor,
      icon: icon ?? this.icon,
    );
  }
}
