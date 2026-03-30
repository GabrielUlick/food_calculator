
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/food_product_provider.dart';
import '../models/food_product.dart';

class FoodProductScreen extends StatefulWidget {
  final FoodProduct? product;

  const FoodProductScreen({
    super.key,
    this.product,
  });

  @override
  State<FoodProductScreen> createState() => _FoodProductScreenState();
}

class _FoodProductScreenState extends State<FoodProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _servingsPerPackageController = TextEditingController();
  final _energyKcalController = TextEditingController();
  final _energyKjController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _totalSugarsController = TextEditingController();
  final _addedSugarsController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatTotalController = TextEditingController();
  final _fatSaturatedController = TextEditingController();
  final _fatTransController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sodiumController = TextEditingController();

  FoodIcon _selectedIcon = FoodIcon.restaurant;
  Color _selectedBorderColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields(widget.product!);
    }
  }

  void _populateFields(FoodProduct product) {
    _nameController.text = product.name;
    _brandController.text = product.brand ?? '';
    _servingSizeController.text = product.servingSize.toString();
    _servingsPerPackageController.text = product.servingsPerPackage?.toString() ?? '';
    _selectedIcon = product.icon;
    // Encontra a cor mais próxima na lista de cores disponíveis
    final availableColors = [Colors.blue, Colors.green, Colors.yellow, Colors.red];
    _selectedBorderColor = availableColors.firstWhere(
      (color) => color.value == product.borderColor.value,
      orElse: () => Colors.blue,
    );
    _energyKcalController.text = product.energyKcal.toString();
    _energyKjController.text = product.energyKj?.toString() ?? '';
    _carbohydratesController.text = product.carbohydrates.toString();
    _totalSugarsController.text = product.totalSugars.toString();
    _addedSugarsController.text = product.addedSugars.toString();
    _proteinsController.text = product.proteins.toString();
    _fatTotalController.text = product.fatTotal.toString();
    _fatSaturatedController.text = product.fatSaturated.toString();
    _fatTransController.text = product.fatTrans.toString();
    _fiberController.text = product.fiber.toString();
    _sodiumController.text = product.sodium.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _servingSizeController.dispose();
    _servingsPerPackageController.dispose();
    _energyKcalController.dispose();
    _energyKjController.dispose();
    _carbohydratesController.dispose();
    _totalSugarsController.dispose();
    _addedSugarsController.dispose();
    _proteinsController.dispose();
    _fatTotalController.dispose();
    _fatSaturatedController.dispose();
    _fatTransController.dispose();
    _fiberController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) {
    try {
      // Substitui vírgula por ponto para permitir ambos os formatos
      return double.parse(value.replaceAll(',', '.'));
    } catch (e) {
      debugPrint('Erro ao converter valor: $value');
      return 0.0;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = FoodProduct(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      servingSize: _parseDouble(_servingSizeController.text),
      servingsPerPackage: _servingsPerPackageController.text.trim().isEmpty 
          ? null 
          : _parseDouble(_servingsPerPackageController.text),
      icon: _selectedIcon,
      borderColor: _selectedBorderColor,
      energyKcal: _parseDouble(_energyKcalController.text),
      energyKj: _energyKjController.text.trim().isEmpty 
          ? null 
          : _parseDouble(_energyKjController.text),
      carbohydrates: _parseDouble(_carbohydratesController.text),
      totalSugars: _parseDouble(_totalSugarsController.text),
      addedSugars: _parseDouble(_addedSugarsController.text),
      proteins: _parseDouble(_proteinsController.text),
      fatTotal: _parseDouble(_fatTotalController.text),
      fatSaturated: _parseDouble(_fatSaturatedController.text),
      fatTrans: _parseDouble(_fatTransController.text),
      fiber: _parseDouble(_fiberController.text),
      sodium: _parseDouble(_sodiumController.text),
    );

    try {
      final provider = Provider.of<FoodProductProvider>(context, listen: false);
      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null 
                ? 'Alimento cadastrado com sucesso!' 
                : 'Alimento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alimento: $e'),
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
        title: Text(widget.product == null ? 'Cadastrar Alimento' : 'Editar Alimento'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Informações Básicas', [
              _buildTextField(
                controller: _nameController,
                label: 'Nome do alimento',
                icon: Icons.restaurant,
                required: true,
              ),
              _buildTextField(
                controller: _brandController,
                label: 'Marca (opcional)',
                icon: Icons.business,
              ),
              _buildTextField(
                controller: _servingSizeController,
                label: 'Porção (g)',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _servingsPerPackageController,
                label: 'Porções por embalagem (opcional)',
                icon: Icons.inventory_2,
                keyboardType: TextInputType.number,
              ),
            ]),
            _buildSection('Aparência', [
              _buildIconSelector(),
              const SizedBox(height: 12),
              _buildColorSelector(),
            ]),
            _buildSection('Informações Energéticas', [
              _buildTextField(
                controller: _energyKcalController,
                label: 'Valor energético (kcal)',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _energyKjController,
                label: 'Valor energético (kJ) - opcional',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
              ),
            ]),
            _buildSection('Carboidratos', [
              _buildTextField(
                controller: _carbohydratesController,
                label: 'Carboidratos (g)',
                icon: Icons.grain,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _totalSugarsController,
                label: 'Açúcares totais (g)',
                icon: Icons.water_drop,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _addedSugarsController,
                label: 'Açúcares adicionados (g)',
                icon: Icons.add_circle,
                keyboardType: TextInputType.number,
                required: true,
              ),
            ]),
            _buildSection('Proteínas e Gorduras', [
              _buildTextField(
                controller: _proteinsController,
                label: 'Proteínas (g)',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _fatTotalController,
                label: 'Gorduras totais (g)',
                icon: Icons.opacity,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _fatSaturatedController,
                label: 'Gorduras saturadas (g)',
                icon: Icons.warning,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _fatTransController,
                label: 'Gorduras trans (g)',
                icon: Icons.block,
                keyboardType: TextInputType.number,
                required: true,
              ),
            ]),
            _buildSection('Outros', [
              _buildTextField(
                controller: _fiberController,
                label: 'Fibras alimentares (g)',
                icon: Icons.eco,
                keyboardType: TextInputType.number,
                required: true,
              ),
              _buildTextField(
                controller: _sodiumController,
                label: 'Sódio (mg)',
                icon: Icons.science,
                keyboardType: TextInputType.number,
                required: true,
              ),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.product == null ? 'Cadastrar Alimento' : 'Salvar Alterações',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ícone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: FoodIcon.values.length,
            itemBuilder: (context, index) {
              final icon = FoodIcon.values[index];
              final isSelected = _selectedIcon == icon;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    icon.iconData,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = [Colors.blue, Colors.green, Colors.yellow, Colors.red];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor da borda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: colors.map((color) {
            final isSelected = _selectedBorderColor == color;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedBorderColor = color;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Este campo é obrigatório';
          }
          if (value != null && value.trim().isNotEmpty && keyboardType == TextInputType.number) {
            final number = double.tryParse(value.replaceAll(',', '.'));
            if (number == null || number < 0) {
              return 'Digite um valor válido';
            }
          }
          return null;
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este alimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<FoodProductProvider>(context, listen: false);
              await provider.deleteProduct(widget.product!.id);
              if (mounted) {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Fecha a tela
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alimento excluído com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
