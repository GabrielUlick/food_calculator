
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:izafit/providers/meal_provider.dart';
import 'package:izafit/providers/food_product_provider.dart';
import 'package:izafit/providers/user_profile_provider.dart';
import 'package:izafit/providers/water_intake_provider.dart';
import 'package:izafit/screens/home_screen.dart';
import 'package:izafit/services/notification_service.dart';
import 'package:izafit/theme/app_theme.dart';

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
        title: 'Izafit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
