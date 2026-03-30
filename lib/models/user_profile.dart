import 'package:flutter/material.dart';

enum WeightGoal {
  lose,
  maintain,
  gain,
}

class UserProfile {
  final String id;
  final double height; // em centímetros
  final double currentWeight; // em kg
  final int age; // em anos
  final String gender; // 'Masculino' ou 'Feminino'
  final double? targetWeight; // em kg
  final WeightGoal? weightGoal;
  final DateTime? targetDate;
  final double dailyCalorieGoal; // em kcal

  UserProfile({
    required this.id,
    required this.height,
    required this.currentWeight,
    required this.age,
    required this.gender,
    this.targetWeight,
    this.weightGoal,
    this.targetDate,
    required this.dailyCalorieGoal,
  });

  // Calcula o IMC
  double get bmi {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return currentWeight / (heightInMeters * heightInMeters);
  }

  // Retorna a classificação do IMC
  String get bmiClassification {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Abaixo do peso';
    if (bmiValue < 24.9) return 'Peso normal';
    if (bmiValue < 29.9) return 'Sobrepeso';
    if (bmiValue < 34.9) return 'Obesidade grau I';
    if (bmiValue < 39.9) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }

  // Retorna a cor baseada na classificação do IMC
  Color get bmiColor {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return Colors.orange;
    if (bmiValue < 24.9) return Colors.green;
    if (bmiValue < 29.9) return Colors.yellow;
    if (bmiValue < 34.9) return Colors.orange;
    if (bmiValue < 39.9) return Colors.red;
    return Colors.red[900]!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'height': height,
      'currentWeight': currentWeight,
      'age': age,
      'gender': gender,
      'targetWeight': targetWeight,
      'weightGoal': weightGoal?.index,
      'targetDate': targetDate?.toIso8601String(),
      'dailyCalorieGoal': dailyCalorieGoal,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      height: map['height'],
      currentWeight: map['currentWeight'],
      age: map['age'],
      gender: map['gender'],
      targetWeight: map['targetWeight'],
      weightGoal: map['weightGoal'] != null ? WeightGoal.values[map['weightGoal']] : null,
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      dailyCalorieGoal: map['dailyCalorieGoal'],
    );
  }

  UserProfile copyWith({
    String? id,
    double? height,
    double? currentWeight,
    int? age,
    String? gender,
    double? targetWeight,
    WeightGoal? weightGoal,
    DateTime? targetDate,
    double? dailyCalorieGoal,
  }) {
    return UserProfile(
      id: id ?? this.id,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      targetWeight: targetWeight ?? this.targetWeight,
      weightGoal: weightGoal ?? this.weightGoal,
      targetDate: targetDate ?? this.targetDate,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    );
  }
}
