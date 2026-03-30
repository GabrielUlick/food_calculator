import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/meal_provider.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'add_food_to_meal_screen.dart';

class MealScreen extends StatefulWidget {
  final MealType type;

  const MealScreen({
    super.key,
    required this.type,
  });

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final meals = provider.getMealsByType(widget.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.displayName),
      ),
      body: meals.isEmpty
          ? _EmptyMealState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _MealItemCard(meal: meal);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFoodOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFoodOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Selecionar da base'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFoodToMealScreen(
                      mealType: widget.type,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Adicionar manualmente'),
              onTap: () {
                Navigator.pop(context);
                _showAddFoodDialog(context, Provider.of<MealProvider>(context, listen: false));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, MealProvider provider) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController proteinsController = TextEditingController();
    final TextEditingController lipidsController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();
    final TextEditingController fibersController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Alimento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do alimento',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (g)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calorias (por 100g)',
                    border: OutlineInputBorder(),
                    suffixText: 'kcal',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: proteinsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Proteínas (por 100g)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lipidsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Lipídios (por 100g)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carboidratos (por 100g)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fibersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fibras (por 100g)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final quantity = double.tryParse(quantityController.text) ?? 0;
                final calories = double.tryParse(caloriesController.text) ?? 0;
                final proteins = double.tryParse(proteinsController.text) ?? 0;
                final lipids = double.tryParse(lipidsController.text) ?? 0;
                final carbs = double.tryParse(carbsController.text) ?? 0;
                final fibers = double.tryParse(fibersController.text) ?? 0;

                if (name.isEmpty || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos corretamente'),
                    ),
                  );
                  return;
                }

                final foodItem = FoodItem(
                  id: const Uuid().v4(),
                  name: name,
                  calories: calories,
                  proteins: proteins,
                  lipids: lipids,
                  carbohydrates: carbs,
                  fibers: fibers,
                  quantity: quantity,
                );

                final meal = Meal(
                  id: const Uuid().v4(),
                  type: widget.type,
                  date: provider.selectedDate,
                  items: [foodItem],
                );

                provider.addMeal(meal);
                provider.addFoodToBase(foodItem);
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMealState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.restaurant_menu,
      title: 'Nenhum alimento adicionado',
      subtitle: 'Toque no + para adicionar',
    );
  }
}

class _MealItemCard extends StatelessWidget {
  final Meal meal;

  const _MealItemCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final item = meal.items.first;
    // Define as cores disponíveis e encontra a cor correspondente pelo valor RGB
    final availableColors = [Colors.blue, Colors.green, Colors.yellow, Colors.red];
    final displayColor = availableColors.firstWhere(
      (color) => color.value == item.borderColor.value,
      orElse: () => Colors.blue,
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        leading: CircleAvatar(
          backgroundColor: displayColor.withOpacity(0.2),
          child: item.icon != null
              ? Icon(
                  item.icon!.iconData,
                  color: displayColor,
                )
              : Text(
                  item.name[0].toUpperCase(),
                  style: TextStyle(
                    color: displayColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${item.quantity.toStringAsFixed(0)}g - ${item.adjustedCalories.toStringAsFixed(0)} kcal',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Deseja realmente excluir este alimento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.deleteMeal(meal.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}