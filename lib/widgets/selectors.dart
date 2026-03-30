
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

// Seletor de gênero padronizado
class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(
              'Masculino',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
            value: 'Masculino',
            groupValue: selectedGender,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            dense: true,
            activeColor: AppTheme.primaryColor,
          ),
          Divider(
            height: 1,
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300],
          ),
          RadioListTile<String>(
            title: Text(
              'Feminino',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
            value: 'Feminino',
            groupValue: selectedGender,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            dense: true,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

// Seletor de data padronizado
class DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? label;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                    : label ?? 'Selecione uma data',
                style: TextStyle(
                  color: selectedDate != null
                      ? (isDarkMode ? Colors.white : AppTheme.textPrimaryColor)
                      : (isDarkMode ? Colors.grey[400] : AppTheme.textSecondaryColor),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
