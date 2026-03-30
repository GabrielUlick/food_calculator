import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/meal_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/water_intake_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final waterProvider = Provider.of<WaterIntakeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalorieProgressCard(provider: mealProvider),
              const SizedBox(height: AppTheme.spacingM),
              _MacronutrientsChart(provider: mealProvider),
              const SizedBox(height: AppTheme.spacingM),
              _WaterProgressCard(provider: waterProvider),
              const SizedBox(height: AppTheme.spacingM),
              _BMICard(provider: userProfileProvider),
              const SizedBox(height: AppTheme.spacingM),
              _WeeklyProgressCard(provider: mealProvider),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalorieProgressCard extends StatelessWidget {
  final MealProvider provider;

  const _CalorieProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final progress = provider.calorieProgress.clamp(0.0, 1.0);
    final remaining = provider.dailyCalorieGoal - provider.totalCalories;
    final progressColor = progress >= 1.0 ? AppTheme.errorColor : AppTheme.primaryColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso Diário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                        value: provider.totalCalories,
                        color: progressColor,
                        radius: 50,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: remaining > 0 ? remaining : 0,
                        color: Colors.grey[300],
                        radius: 50,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'da meta',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                label: 'Consumidas',
                value: '${provider.totalCalories.toStringAsFixed(0)} kcal',
                color: progressColor,
                icon: Icons.local_fire_department,
              ),
              StatCard(
                label: 'Restantes',
                value: '${remaining > 0 ? remaining.toStringAsFixed(0) : 0} kcal',
                color: Colors.grey[600]!,
                icon: Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterProgressCard extends StatelessWidget {
  final WaterIntakeProvider provider;

  const _WaterProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final progress = provider.waterProgress.clamp(0.0, 1.0);
    final remaining = provider.dailyWaterGoal - provider.totalWaterIntake;
    final progressColor = progress >= 1.0 ? AppTheme.successColor : AppTheme.infoColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso de Hidratação',
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
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
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
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                label: 'Consumido',
                value: '${provider.totalWaterIntake.toStringAsFixed(0)} ml',
                color: progressColor,
                icon: Icons.water_drop,
              ),
              StatCard(
                label: 'Restante',
                value: '${remaining > 0 ? remaining.toStringAsFixed(0) : 0} ml',
                color: Colors.grey[600]!,
                icon: Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BMICard extends StatelessWidget {
  final UserProfileProvider provider;

  const _BMICard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final profile = provider.userProfile;
    
    if (profile == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Índice de Massa Corporal (IMC)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            const EmptyState(
              icon: Icons.person_outline,
              title: 'Configure seu perfil para ver o IMC',
            ),
          ],
        ),
      );
    }

    final bmi = profile!.bmi;
    final bmiClassification = profile!.bmiClassification;
    final bmiColor = profile!.bmiColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Índice de Massa Corporal (IMC)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bmiColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bmiClassification,
                      style: TextStyle(
                        color: bmiColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatCard(
                    label: 'Peso Atual',
                    value: '${profile!.currentWeight.toStringAsFixed(1)} kg',
                    color: Colors.grey[700]!,
                    icon: Icons.monitor_weight,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  StatCard(
                    label: 'Altura',
                    value: '${profile!.height.toStringAsFixed(0)} cm',
                    color: Colors.grey[700]!,
                    icon: Icons.height,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _StatItem foi substituído por StatCard do app_widgets.dart

class _MacronutrientsChart extends StatelessWidget {
  final MealProvider provider;

  const _MacronutrientsChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(provider),
                barGroups: [
                  _buildBarGroup(0, provider.totalProteins, AppTheme.proteinColor),
                  _buildBarGroup(1, provider.totalCarbohydrates, AppTheme.carbohydrateColor),
                  _buildBarGroup(2, provider.totalLipids, AppTheme.lipidColor),
                  _buildBarGroup(3, provider.totalFibers, AppTheme.fiberColor),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Proteínas');
                          case 1:
                            return const Text('Carbos');
                          case 2:
                            return const Text('Lipídios');
                          case 3:
                            return const Text('Fibras');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  double _getMaxValue(MealProvider provider) {
    final values = [
      provider.totalProteins,
      provider.totalCarbohydrates,
      provider.totalLipids,
      provider.totalFibers,
    ];
    final max = values.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  final MealProvider provider;

  const _WeeklyProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso da Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _WeeklyChart(provider: provider),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final MealProvider provider;

  const _WeeklyChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(days[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _getWeeklySpots(provider),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getWeeklySpots(MealProvider provider) {
    final weeklyCalories = provider.getWeeklyCalories();
    return [
      FlSpot(0, weeklyCalories[0] ?? 0),
      FlSpot(1, weeklyCalories[1] ?? 0),
      FlSpot(2, weeklyCalories[2] ?? 0),
      FlSpot(3, weeklyCalories[3] ?? 0),
      FlSpot(4, weeklyCalories[4] ?? 0),
      FlSpot(5, weeklyCalories[5] ?? 0),
      FlSpot(6, weeklyCalories[6] ?? 0),
    ];
  }
}