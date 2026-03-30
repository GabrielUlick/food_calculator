
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calculator/providers/meal_provider.dart';
import 'package:food_calculator/providers/food_product_provider.dart';
import 'package:food_calculator/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MealProvider()),
        ChangeNotifierProvider(create: (context) => FoodProductProvider()),
      ],
      child: MaterialApp(
        title: 'Calculadora de Calorias',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
