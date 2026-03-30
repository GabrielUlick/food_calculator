import 'package:flutter/material.dart';

class WaterIntake {
  final String id;
  final DateTime date;
  final double amount; // em ml
  final String type; // 'copo' ou 'garrafa'
  final double? capacity; // capacidade em ml (apenas para garrafa)

  WaterIntake({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.capacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
      'capacity': capacity,
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      type: map['type'],
      capacity: map['capacity'],
    );
  }

  WaterIntake copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? type,
    double? capacity,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
    );
  }
}

class WaterBottle {
  final String id;
  final String name;
  final double capacity; // em ml
  final Color color;

  WaterBottle({
    required this.id,
    required this.name,
    required this.capacity,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'color': color.value,
    };
  }

  factory WaterBottle.fromMap(Map<String, dynamic> map) {
    return WaterBottle(
      id: map['id'],
      name: map['name'],
      capacity: map['capacity'],
      color: Color(map['color']),
    );
  }

  WaterBottle copyWith({
    String? id,
    String? name,
    double? capacity,
    Color? color,
  }) {
    return WaterBottle(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      color: color ?? this.color,
    );
  }
}
