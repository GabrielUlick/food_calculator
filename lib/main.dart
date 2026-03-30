
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calculator/providers/meal_provider.dart';
import 'package:food_calculator/providers/food_product_provider.dart';
import 'package:food_calculator/providers/user_profile_provider.dart';
import 'package:food_calculator/providers/water_intake_provider.dart';
import 'package:food_calculator/screens/home_screen.dart';
import 'package:food_calculator/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
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
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => WaterIntakeProvider()),
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
