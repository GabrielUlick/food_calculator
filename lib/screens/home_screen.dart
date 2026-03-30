import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/meal_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/water_intake_provider.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'meal_screen.dart';
import 'dashboard_screen.dart';
import 'food_products_list_screen.dart';
import 'imc_screen.dart';
import 'water_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('HomeScreen - Iniciando carregamento de dados...');
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      final waterProvider = Provider.of<WaterIntakeProvider>(context, listen: false);

      debugPrint('HomeScreen - Carregando meta diária de calorias do banco...');
      await mealProvider.loadDailyCalorieGoal();
      debugPrint('HomeScreen - Meta diária de calorias carregada: ${mealProvider.dailyCalorieGoal}');

      debugPrint('HomeScreen - Carregando refeições...');
      await mealProvider.loadMealsByDate(DateTime.now());
      debugPrint('HomeScreen - Carregando base de alimentos...');
      await mealProvider.loadFoodBase();
      // Carrega dados da semana para o dashboard
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      await mealProvider.loadMealsByDateRange(startOfWeek, endOfWeek);
      debugPrint('HomeScreen - Carregando perfil do usuário...');
      await userProfileProvider.loadUserProfile();
      debugPrint('HomeScreen - Perfil carregado: ${userProfileProvider.userProfile?.toMap()}');

      // Carrega a meta diária de calorias do perfil do usuário
      if (userProfileProvider.userProfile != null) {
        final calorieGoal = userProfileProvider.userProfile!.dailyCalorieGoal;
        debugPrint('HomeScreen - Definindo meta diária de calorias do perfil: $calorieGoal');
        mealProvider.setDailyCalorieGoal(calorieGoal);
      } else {
        debugPrint('HomeScreen - Nenhum perfil encontrado, usando meta padrão');
      }

      // Carrega dados do controle de água
      debugPrint('HomeScreen - Carregando dados do controle de água...');
      await waterProvider.loadWaterIntakesByDate(DateTime.now());
      await waterProvider.loadBottles();
      await waterProvider.loadDailyWaterGoal();
      await waterProvider.loadNotificationSettings();
      // Carrega dados da semana para o dashboard (reutilizando as variáveis já declaradas)
      await waterProvider.loadWaterIntakesByDateRange(startOfWeek, endOfWeek);
      debugPrint('HomeScreen - Dados do controle de água carregados');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Calorias'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodProductsListScreen(),
                ),
              );
            },
            tooltip: 'Meus Alimentos',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: const [
            _DailyView(),
            DashboardScreen(),
            WaterScreen(),
            IMCScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Refeições',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Água',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'IMC',
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<MealProvider>(context, listen: false);
    final TextEditingController goalController = TextEditingController(text: provider.dailyCalorieGoal.toStringAsFixed(0));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                Icons.settings,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(
              'Configurações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C).withOpacity(0.5)
                      : AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2C2C)
                        : AppTheme.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        'Defina sua meta diária de calorias para acompanhar sua alimentação.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              AppTextField(
                controller: goalController,
                label: 'Meta diária de calorias',
                keyboardType: TextInputType.number,
                suffixText: 'kcal',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Sugestões de metas:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: [
                  _buildSuggestionChip(context, '1500', goalController),
                  _buildSuggestionChip(context, '1800', goalController),
                  _buildSuggestionChip(context, '2000', goalController),
                  _buildSuggestionChip(context, '2500', goalController),
                  _buildSuggestionChip(context, '3000', goalController),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = double.tryParse(goalController.text);
              if (goal != null && goal > 0) {
                provider.setDailyCalorieGoal(goal);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: AppTheme.spacingS),
                        Text('Meta diária atualizada com sucesso!'),
                      ],
                    ),
                    backgroundColor: AppTheme.successColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, insira um valor válido.'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String value, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ActionChip(
      label: Text('$value kcal'),
      onPressed: () {
        controller.text = value;
      },
      backgroundColor: isDark 
          ? const Color(0xFF2C2C2C).withOpacity(0.5)
          : AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isDark ? Colors.white : AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isDark 
            ? const Color(0xFF2C2C2C)
            : AppTheme.primaryColor.withOpacity(0.3),
      ),
    );
  }
}

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        // Seletor de data
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => provider.changeDate(
                  provider.selectedDate.subtract(const Duration(days: 1)),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context, provider),
                child: Text(
                  dateFormat.format(provider.selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => provider.changeDate(
                  provider.selectedDate.add(const Duration(days: 1)),
                ),
              ),
            ],
          ),
        ),
        // Resumo diário
        _DailySummary(),
        const SizedBox(height: 16),
        // Lista de refeições
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MealType.values.length,
            itemBuilder: (context, index) {
              final type = MealType.values[index];
              final meals = provider.getMealsByType(type);
              return _MealCard(type: type, meals: meals);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, MealProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      provider.changeDate(picked);
    }
  }
}

class _DailySummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final progress = provider.calorieProgress.clamp(0.0, 1.0);
    final progressColor = progress >= 1.0 ? AppTheme.errorColor : AppTheme.primaryColor;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumo do Dia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Text(
                  '${provider.totalCalories.toStringAsFixed(0)} / ${provider.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          AppProgressBar(
            value: progress,
            color: progressColor,
            height: 10,
            showPercentage: false,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NutrientCard(
                label: 'Proteínas',
                value: provider.totalProteins,
                unit: 'g',
                color: AppTheme.proteinColor,
                icon: Icons.fitness_center,
              ),
              NutrientCard(
                label: 'Carboidratos',
                value: provider.totalCarbohydrates,
                unit: 'g',
                color: AppTheme.carbohydrateColor,
                icon: Icons.grain,
              ),
              NutrientCard(
                label: 'Lipídios',
                value: provider.totalLipids,
                unit: 'g',
                color: AppTheme.lipidColor,
                icon: Icons.water_drop,
              ),
              NutrientCard(
                label: 'Fibras',
                value: provider.totalFibers,
                unit: 'g',
                color: AppTheme.fiberColor,
                icon: Icons.eco,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Removido - agora usando NutrientCard do app_widgets.dart

class _MealCard extends StatelessWidget {
  final MealType type;
  final List<Meal> meals;

  const _MealCard({
    required this.type,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForMealType(type);
    final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.totalCalories);
    final isComplete = meals.isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealScreen(type: type),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getIconForMealType(type),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isComplete ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isComplete ? AppTheme.successColor : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meals.length} ${meals.length == 1 ? 'item' : 'itens'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Text(
              '${totalCalories.toStringAsFixed(0)} kcal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Color _getColorForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppTheme.warningColor;
      case MealType.lunch:
        return AppTheme.primaryColor;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return AppTheme.infoColor;
    }
  }

  IconData _getIconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}