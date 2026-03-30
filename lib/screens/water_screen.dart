import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/water_intake_provider.dart';
import '../models/water_intake.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/water_settings_dialog.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
      await provider.loadWaterIntakesByDate(DateTime.now());
      await provider.loadBottles();
      await provider.loadDailyWaterGoal();
      await provider.loadNotificationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<WaterIntakeProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCard(provider),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildQuickActions(provider),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildBottlesSection(provider),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildIntakesList(provider),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(WaterIntakeProvider provider) {
    final progress = provider.waterProgress.clamp(0.0, 1.0);
    final remaining = provider.dailyWaterGoal - provider.totalWaterIntake;
    final progressColor = progress >= 1.0 ? AppTheme.successColor : AppTheme.infoColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        onTap: () => _showSettingsDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: progressColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Progresso Diário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: progressColor.withOpacity(0.3),
                    ),
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
                Expanded(
                  child: _ProgressStatCard(
                    label: 'Consumido',
                    value: '${provider.totalWaterIntake.toStringAsFixed(0)} ml',
                    color: progressColor,
                    icon: Icons.water_drop,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _ProgressStatCard(
                    label: 'Restante',
                    value: '${remaining > 0 ? remaining.toStringAsFixed(0) : 0} ml',
                    color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    icon: Icons.timer,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(WaterIntakeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Adicionar Água',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.local_drink,
                label: 'Copo\n200ml',
                onTap: () => _addWaterIntake(provider, 200, 'copo'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.local_cafe,
                label: 'Caneca\n300ml',
                onTap: () => _addWaterIntake(provider, 300, 'copo'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.water_drop,
                label: 'Garrafa\n500ml',
                onTap: () => _addWaterIntake(provider, 500, 'garrafa'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottlesSection(WaterIntakeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Minhas Garrafas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddBottleDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppTheme.primaryColor : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (provider.bottles.isEmpty)
          const EmptyState(
            icon: Icons.water_drop_outlined,
            title: 'Nenhuma garrafa cadastrada',
            subtitle: 'Adicione uma garrafa para começar a rastrear sua hidratação',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: AppTheme.spacingM,
              mainAxisSpacing: AppTheme.spacingM,
            ),
            itemCount: provider.bottles.length,
            itemBuilder: (context, index) {
              final bottle = provider.bottles[index];
              return _BottleCard(
                bottle: bottle,
                onTap: () => _addWaterIntake(provider, bottle.capacity, 'garrafa', bottle.capacity),
                onLongPress: () => _showBottleOptions(context, provider, bottle),
              );
            },
          ),
      ],
    );
  }

  Widget _buildIntakesList(WaterIntakeProvider provider) {
    final intakes = provider.getIntakesByDate(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Histórico do Dia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (intakes.isEmpty)
          const EmptyState(
            icon: Icons.history,
            title: 'Nenhum registro hoje',
            subtitle: 'Beba água e comece a rastrear sua hidratação',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intakes.length,
            itemBuilder: (context, index) {
              final intake = intakes[index];
              return _IntakeListItem(
                intake: intake,
                onDelete: () => _deleteIntake(provider, intake.id),
              );
            },
          ),
      ],
    );
  }

  Future<void> _addWaterIntake(
      WaterIntakeProvider provider,
      double amount,
      String type, [
        double? capacity,
      ]) async {
    final intake = WaterIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      type: type,
      capacity: capacity,
    );
    await provider.addWaterIntake(intake);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${amount.toStringAsFixed(0)}ml adicionado!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteIntake(WaterIntakeProvider provider, String id) async {
    await provider.deleteWaterIntake(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro removido!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WaterSettingsDialog(),
    );
  }

  void _showAddBottleDialog(BuildContext context, WaterIntakeProvider provider) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Garrafa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Garrafa do escritório',
                ),
              ),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidade (ml)',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Cor:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ColorOption(
                    color: Colors.blue,
                    isSelected: selectedColor == Colors.blue,
                    onTap: () => setState(() => selectedColor = Colors.blue),
                  ),
                  _ColorOption(
                    color: Colors.green,
                    isSelected: selectedColor == Colors.green,
                    onTap: () => setState(() => selectedColor = Colors.green),
                  ),
                  _ColorOption(
                    color: Colors.orange,
                    isSelected: selectedColor == Colors.orange,
                    onTap: () => setState(() => selectedColor = Colors.orange),
                  ),
                  _ColorOption(
                    color: Colors.purple,
                    isSelected: selectedColor == Colors.purple,
                    onTap: () => setState(() => selectedColor = Colors.purple),
                  ),
                  _ColorOption(
                    color: Colors.pink,
                    isSelected: selectedColor == Colors.pink,
                    onTap: () => setState(() => selectedColor = Colors.pink),
                  ),
                  _ColorOption(
                    color: Colors.teal,
                    isSelected: selectedColor == Colors.teal,
                    onTap: () => setState(() => selectedColor = Colors.teal),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final capacity = double.tryParse(capacityController.text);
                if (name.isNotEmpty && capacity != null && capacity > 0) {
                  final bottle = WaterBottle(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    capacity: capacity,
                    color: selectedColor,
                  );
                  provider.addBottle(bottle);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottleOptions(BuildContext context, WaterIntakeProvider provider, WaterBottle bottle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bottle.name),
        content: Text('Capacidade: ${bottle.capacity.toStringAsFixed(0)} ml'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBottle(bottle.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF2C2C2C).withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF2C2C2C)
                : AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottleCard extends StatelessWidget {
  final WaterBottle bottle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BottleCard({
    required this.bottle,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF2C2C2C).withOpacity(0.5)
              : bottle.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF2C2C2C)
                : bottle.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop,
              color: bottle.color,
              size: 32,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              bottle.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${bottle.capacity.toStringAsFixed(0)} ml',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntakeListItem extends StatelessWidget {
  final WaterIntake intake;
  final VoidCallback onDelete;

  const _IntakeListItem({
    required this.intake,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF2C2C2C).withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF2C2C2C)
              : AppTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              intake.type == 'copo' ? Icons.local_drink : Icons.water_drop,
              color: AppTheme.infoColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intake.type == 'copo' ? 'Copo' : 'Garrafa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(intake.date),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${intake.amount.toStringAsFixed(0)} ml',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.infoColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ProgressStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF2C2C2C).withOpacity(0.5)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF2C2C2C)
              : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : color,
            ),
          ),
        ],
      ),
    );
  }
}
