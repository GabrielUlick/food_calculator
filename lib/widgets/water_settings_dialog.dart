 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_intake_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class WaterSettingsDialog extends StatefulWidget {
  const WaterSettingsDialog({super.key});

  @override
  State<WaterSettingsDialog> createState() => _WaterSettingsDialogState();
}

class _WaterSettingsDialogState extends State<WaterSettingsDialog> {
  late TextEditingController _goalController;
  late int _tempInterval;
  late bool _tempNotificationsEnabled;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
    _tempInterval = provider.notificationInterval;
    _tempNotificationsEnabled = provider.notificationsEnabled;
    _goalController = TextEditingController(
      text: provider.dailyWaterGoal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final infoColor = AppTheme.infoColor;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      title: Row(
        children: [
          Icon(
            Icons.water_drop,
            color: infoColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            'Configurações de Água',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _goalController,
              label: 'Meta diária de água',
              keyboardType: TextInputType.number,
              suffixText: 'ml',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF2C2C2C).withOpacity(0.5)
                    : infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF2C2C2C)
                      : infoColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Lembretes de Hidratação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  SwitchListTile(
                    title: Text(
                      'Ativar notificações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                      ),
                    ),
                    subtitle: Text(
                      'Receba lembretes para beber água',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondaryColor,
                      ),
                    ),
                    value: _tempNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _tempNotificationsEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: infoColor,
                  ),
                  if (_tempNotificationsEnabled) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Intervalo entre notificações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: infoColor,
                        inactiveTrackColor: isDark 
                            ? Colors.grey[700]
                            : infoColor.withOpacity(0.3),
                        thumbColor: infoColor,
                        overlayColor: infoColor.withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _tempInterval.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11,
                        label: '$_tempInterval min',
                        onChanged: (value) {
                          setState(() {
                            _tempInterval = value.toInt();
                          });
                        },
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? const Color(0xFF2C2C2C).withOpacity(0.5)
                              : infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          border: Border.all(
                            color: isDark 
                                ? const Color(0xFF2C2C2C)
                                : infoColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$_tempInterval minutos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: infoColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      _getIntervalDescription(_tempInterval),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark ? AppTheme.primaryColor : null,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final provider = Provider.of<WaterIntakeProvider>(context, listen: false);

            // Atualiza a meta diária
            final goal = double.tryParse(_goalController.text);
            if (goal != null && goal > 0) {
              provider.setDailyWaterGoal(goal);
            }

            // Atualiza as configurações de notificação
            if (_tempNotificationsEnabled != provider.notificationsEnabled) {
              await provider.setNotificationsEnabled(_tempNotificationsEnabled);
            }

            // Atualiza o intervalo se for diferente
            if (_tempInterval != provider.notificationInterval) {
              await provider.setNotificationInterval(_tempInterval);
            }

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Configurações salvas com sucesso!'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  String _getIntervalDescription(int minutes) {
    if (minutes <= 30) {
      return 'Lembretes frequentes para manter-se bem hidratado';
    } else if (minutes <= 60) {
      return 'Intervalo moderado, ideal para o dia a dia';
    } else if (minutes <= 120) {
      return 'Intervalo espaçado, para quem já tem o hábito';
    } else {
      return 'Lembretes ocasionais para não esquecer de beber água';
    }
  }
}
