import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/water_intake_provider.dart';
import '../models/water_intake.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

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

    return AppCard(
      onTap: () => _showSettingsDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso Diário',
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

  Widget _buildQuickActions(WaterIntakeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adicionar Água',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Minhas Garrafas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddBottleDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico do Dia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
    // Variável temporária para armazenar o intervalo selecionado - deve estar fora do Consumer
    int tempInterval = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer<WaterIntakeProvider>(
            builder: (context, provider, child) {
              // Variável temporária para armazenar o intervalo selecionado
              int tempInterval = provider.notificationInterval;
              // Inicializa o controlador apenas uma vez
              final goalController = TextEditingController(text: provider.dailyWaterGoal.toStringAsFixed(0));

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                title: const Text('Configurações'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: goalController,
                      label: 'Meta diária de água',
                      keyboardType: TextInputType.number,
                      suffixText: 'ml',
                      icon: Icons.local_fire_department,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    SwitchListTile(
                      title: const Text('Notificações'),
                      subtitle: const Text('Lembrete para beber água'),
                      value: provider.notificationsEnabled,
                      onChanged: (value) {
                        provider.setNotificationsEnabled(value);
                      },
                    ),
                    if (provider.notificationsEnabled) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      const Text('Intervalo de notificações:'),
                      Slider(
                        value: tempInterval.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11,
                        label: '$tempInterval min',
                        onChanged: (value) {
                          // Atualiza apenas a variável temporária, não o provider
                          setState(() {
                            tempInterval = value.toInt();
                          });
                        },
                      ),
                      Text(
                        '$tempInterval minutos',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final goal = double.tryParse(goalController.text);
                      if (goal != null && goal > 0) {
                        provider.setDailyWaterGoal(goal);
                      }
                      // Só atualiza o intervalo se for diferente do atual
                      if (tempInterval != provider.notificationInterval) {
                        provider.setNotificationInterval(tempInterval);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              );
            },
          );
        },
      ),
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
            TextButton(
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
              child: const Text('Adicionar'),
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
        content: Text('Capacidade: ${bottle.capacity.toStringAsFixed(0)}ml'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditBottleDialog(context, provider, bottle);
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteBottle(bottle.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showEditBottleDialog(BuildContext context, WaterIntakeProvider provider, WaterBottle bottle) {
    final nameController = TextEditingController(text: bottle.name);
    final capacityController = TextEditingController(text: bottle.capacity.toStringAsFixed(0));
    Color selectedColor = bottle.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Garrafa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
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
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final capacity = double.tryParse(capacityController.text);
                if (name.isNotEmpty && capacity != null && capacity > 0) {
                  final updatedBottle = bottle.copyWith(
                    name: name,
                    capacity: capacity,
                    color: selectedColor,
                  );
                  provider.updateBottle(updatedBottle);
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

  void _requestNotificationPermission() {
    // TODO: Implementar solicitação de permissão de notificação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de notificação será implementada em breve!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
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
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bottle.color.withOpacity(0.1),
          border: Border.all(color: bottle.color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop,
              color: bottle.color,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              bottle.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bottle.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${bottle.capacity.toStringAsFixed(0)}ml',
              style: TextStyle(
                color: bottle.color.withOpacity(0.7),
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
    final time = DateFormat.Hm().format(intake.date);
    final icon = intake.type == 'copo' ? Icons.local_drink : Icons.water_drop;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text('${intake.amount.toStringAsFixed(0)}ml'),
        subtitle: Text(time),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}
