import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../providers/meal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/selectors.dart';

class IMCScreen extends StatefulWidget {
  const IMCScreen({super.key});

  @override
  State<IMCScreen> createState() => _IMCScreenState();
}

class _IMCScreenState extends State<IMCScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'Masculino';
  WeightGoal? _selectedGoal;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    debugPrint('InitState da tela IMC');

    // Carrega o perfil do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('PostFrameCallback - Carregando perfil...');
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.loadUserProfile();
      debugPrint('PostFrameCallback - Perfil carregado: ${profileProvider.userProfile?.toMap()}');
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Mostra indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final mealProvider = Provider.of<MealProvider>(context, listen: false);

      final height = double.parse(_heightController.text);
      final currentWeight = double.parse(_weightController.text);
      final age = int.parse(_ageController.text);

      double? targetWeight;
      DateTime? targetDate;

      if (_selectedGoal != null && _selectedGoal != WeightGoal.maintain) {
        targetWeight = double.parse(_targetWeightController.text);
        targetDate = _targetDate;
      }

      // Calcula a meta diária de calorias
      final dailyCalorieGoal = profileProvider.calculateDailyCalorieGoal(
        height: height,
        currentWeight: currentWeight,
        age: age,
        gender: _gender,
        weightGoal: _selectedGoal ?? WeightGoal.maintain,
        targetDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
        targetWeight: targetWeight,
      );

      final profile = UserProfile(
        id: '1',
        height: height,
        currentWeight: currentWeight,
        age: age,
        gender: _gender,
        targetWeight: targetWeight,
        weightGoal: _selectedGoal,
        targetDate: targetDate,
        dailyCalorieGoal: dailyCalorieGoal,
      );

      await profileProvider.saveUserProfile(profile);

      // Atualiza a meta diária de calorias no MealProvider
      debugPrint('IMCScreen - Atualizando meta diária de calorias no MealProvider: $dailyCalorieGoal');
      mealProvider.setDailyCalorieGoal(dailyCalorieGoal);
      debugPrint('IMCScreen - Meta diária de calorias definida: ${mealProvider.dailyCalorieGoal}');

      if (mounted) {
        Navigator.pop(context); // Fecha o indicador de carregamento

        // Mostra diálogo de sucesso
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Perfil salvo com sucesso!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${dailyCalorieGoal.toStringAsFixed(0)} kcal/dia',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fecha o indicador de carregamento

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.userProfile;

    debugPrint('Build da tela IMC - Profile: ${profile?.toMap()}');
    debugPrint('HeightController: ${_heightController.text}');

    // Se já existe um perfil, preenche os campos
    if (profile != null && _heightController.text.isEmpty) {
      debugPrint('Preenchendo campos com dados do perfil...');
      _heightController.text = profile.height.toString();
      _weightController.text = profile.currentWeight.toString();
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
      _selectedGoal = profile.weightGoal;
      if (profile.targetWeight != null) {
        _targetWeightController.text = profile.targetWeight.toString();
      }
      _targetDate = profile.targetDate;
      debugPrint('Campos preenchidos com sucesso');
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção de Dados Pessoais
                    _buildSectionHeader(
                      'Dados Pessoais',
                      Icons.person,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    _buildInputCard(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _heightController,
                            label: 'Altura',
                            suffix: 'cm',
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua altura';
                              }
                              final height = double.tryParse(value);
                              if (height == null || height <= 0 || height > 300) {
                                return 'Altura inválida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _weightController,
                            label: 'Peso Atual',
                            suffix: 'kg',
                            icon: Icons.scale,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu peso atual';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0 || weight > 500) {
                                return 'Peso inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _ageController,
                            label: 'Idade',
                            suffix: 'anos',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua idade';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age <= 0 || age > 120) {
                                return 'Idade inválida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildGenderSelector(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Seção de Objetivo de Peso
                    _buildSectionHeader(
                      'Objetivo de Peso',
                      Icons.flag,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalSelector(),
                    const SizedBox(height: 16),
                    if (_selectedGoal != null && _selectedGoal != WeightGoal.maintain) ...[
                      _buildInputCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _targetWeightController,
                              label: 'Peso Alvo',
                              suffix: 'kg',
                              icon: Icons.track_changes,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu peso alvo';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null || weight <= 0 || weight > 500) {
                                  return 'Peso inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDateSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSuggestedDateButton(),
                    ],
                    const SizedBox(height: 24),

                    // Resultado do IMC
                    if (profile != null) ...[
                      _buildBMIResult(profile),
                      const SizedBox(height: 16),
                      _buildCalorieGoal(profile),
                    ],
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    if (profile != null) ...[
                      const SizedBox(height: 16),
                      _buildDeleteButton(),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        elevated: true,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      suffixText: suffix,
      icon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildGenderSelector() {
    return GenderSelector(
      selectedGender: _gender,
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
    );
  }

  Widget _buildGoalSelector() {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        elevated: true,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _buildGoalOption(
              title: 'Perder Peso',
              icon: Icons.trending_down,
              color: AppTheme.warningColor,
              value: WeightGoal.lose,
            ),
            const Divider(height: 1),
            _buildGoalOption(
              title: 'Manter Peso',
              icon: Icons.trending_flat,
              color: AppTheme.successColor,
              value: WeightGoal.maintain,
            ),
            const Divider(height: 1),
            _buildGoalOption(
              title: 'Ganhar Peso',
              icon: Icons.trending_up,
              color: AppTheme.infoColor,
              value: WeightGoal.gain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption({
    required String title,
    required IconData icon,
    required Color color,
    required WeightGoal value,
  }) {
    final isSelected = _selectedGoal == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return DateSelector(
      selectedDate: _targetDate,
      onTap: () => _selectDate(context),
      label: 'Selecione uma data',
    );
  }

  Widget _buildSuggestedDateButton() {
    return TextButton.icon(
      onPressed: () {
        if (_weightController.text.isNotEmpty && _targetWeightController.text.isNotEmpty) {
          final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
          final currentWeight = double.parse(_weightController.text);
          final targetWeight = double.parse(_targetWeightController.text);
          final suggestedDate = profileProvider.getSuggestedTargetDate(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            weightGoal: _selectedGoal!,
          );
          setState(() {
            _targetDate = suggestedDate;
          });
        }
      },
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Usar data sugerida'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBMIResult(UserProfile profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              profile.bmiColor.withOpacity(0.2),
              profile.bmiColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Seu IMC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: profile.bmiColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: profile.bmiColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  profile.bmi.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: profile.bmiColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.bmiClassification,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: profile.bmiColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieGoal(UserProfile profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meta Diária de Calorias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    profile.dailyCalorieGoal.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (profile.targetDate != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Para atingir ${profile.targetWeight?.toStringAsFixed(1)} kg até ${DateFormat('dd/MM/yyyy').format(profile.targetDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            SizedBox(width: 8),
            Text(
              'Salvar Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir Perfil'),
              content: const Text('Tem certeza que deseja excluir seu perfil? Esta ação não pode ser desfeita.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
                    await profileProvider.deleteUserProfile();

                    // Limpa os campos
                    _heightController.clear();
                    _weightController.clear();
                    _ageController.clear();
                    _targetWeightController.clear();
                    _gender = 'Masculino';
                    _selectedGoal = null;
                    _targetDate = null;

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perfil excluído com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.red),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Excluir Perfil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
