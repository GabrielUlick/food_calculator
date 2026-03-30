
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_product_provider.dart';
import '../models/food_product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'food_product_screen.dart';

class FoodProductsListScreen extends StatefulWidget {
  const FoodProductsListScreen({super.key});

  @override
  State<FoodProductsListScreen> createState() => _FoodProductsListScreenState();
}

class _FoodProductsListScreenState extends State<FoodProductsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Provider.of<FoodProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Alimentos'),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: AppTextField(
              controller: _searchController,
              label: 'Buscar alimentos...',
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
                  return const EmptyState(
                    icon: Icons.restaurant_menu,
                    title: 'Nenhum alimento encontrado',
                    subtitle: 'Adicione um novo alimento usando o botão +',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _FoodProductCard(
                        product: product,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodProductScreen(
                                product: product,
                              ),
                            ),
                          );
                          _refresh();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodProductScreen(),
            ),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FoodProductCard extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback onTap;

  const _FoodProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: onTap,
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
                      const SizedBox(height: AppTheme.spacingXS),
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
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.carbohydrateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '${product.energyKcal.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    color: AppTheme.carbohydrateColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Porção: ${product.servingSize.toStringAsFixed(0)}g',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: AppTheme.spacingM,
            runSpacing: AppTheme.spacingS,
            children: [
              NutrientChip(
                label: 'Carboidratos',
                value: product.carbohydrates,
                unit: 'g',
                color: AppTheme.carbohydrateColor,
              ),
              NutrientChip(
                label: 'Proteínas',
                value: product.proteins,
                unit: 'g',
                color: AppTheme.proteinColor,
              ),
              NutrientChip(
                label: 'Gorduras',
                value: product.fatTotal,
                unit: 'g',
                color: AppTheme.lipidColor,
              ),
              NutrientChip(
                label: 'Fibras',
                value: product.fiber,
                unit: 'g',
                color: AppTheme.fiberColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _NutrientChip foi substituído por NutrientChip do app_widgets.dart
