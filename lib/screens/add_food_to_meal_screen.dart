
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/food_product_provider.dart';
import '../providers/meal_provider.dart';
import '../models/food_product.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AddFoodToMealScreen extends StatefulWidget {
  final MealType mealType;

  const AddFoodToMealScreen({
    super.key,
    required this.mealType,
  });

  @override
  State<AddFoodToMealScreen> createState() => _AddFoodToMealScreenState();
}

class _AddFoodToMealScreenState extends State<AddFoodToMealScreen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  FoodProduct? _selectedProduct;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addFoodToMeal() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um alimento')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma quantidade válida')),
      );
      return;
    }

    // Calcula os nutrientes baseados na quantidade
    final nutrients = _selectedProduct!.calculateNutrients(quantity);

    final foodItem = FoodItem(
      id: const Uuid().v4(),
      name: _selectedProduct!.name,
      calories: nutrients['energyKcal']!,
      proteins: nutrients['proteins']!,
      lipids: nutrients['fatTotal']!,
      carbohydrates: nutrients['carbohydrates']!,
      fibers: nutrients['fiber']!,
      quantity: quantity,
      borderColor: _selectedProduct!.borderColor,
      icon: _selectedProduct!.icon,
    );

    final meal = Meal(
      id: const Uuid().v4(),
      type: widget.mealType,
      date: Provider.of<MealProvider>(context, listen: false).selectedDate,
      items: [foodItem],
    );

    try {
      await Provider.of<MealProvider>(context, listen: false).addMeal(meal);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedProduct!.name} adicionado à ${widget.mealType.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar alimento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar à ${widget.mealType.displayName}'),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              label: 'Buscar alimentos',
              hint: 'Digite o nome do alimento',
              icon: Icons.search,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<FoodProductProvider>(context, listen: false)
                            .searchProducts('');
                      },
                    )
                  : null,
              onChanged: (value) {
                Provider.of<FoodProductProvider>(context, listen: false)
                    .searchProducts(value);
              },
            ),
          ),
          // Lista de produtos
          Expanded(
            child: Consumer<FoodProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = provider.searchResults;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum alimento encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isSelected = _selectedProduct?.id == product.id;
                    return _FoodProductCard(
                      product: product,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedProduct = product;
                          _quantityController.text = product.servingSize.toStringAsFixed(0);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Painel inferior com quantidade e botão adicionar
          if (_selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selectedProduct!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _quantityController,
                          label: 'Quantidade',
                          suffixText: 'g',
                          icon: Icons.scale,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addFoodToMeal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Adicionar'),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedProduct != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Porção padrão: ${_selectedProduct!.servingSize.toStringAsFixed(0)}g',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FoodProductCard extends StatelessWidget {
  final FoodProduct product;
  final bool isSelected;
  final VoidCallback onTap;

  const _FoodProductCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (product.brand != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.brand!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.energyKcal.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Porção: ${product.servingSize.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
