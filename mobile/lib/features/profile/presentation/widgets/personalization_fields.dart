import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';

class PersonalizationFieldStyle {
  static Color softColor(BuildContext context) => AppColors.of(context).blob;
  static Color borderColor(BuildContext context) =>
      AppColors.of(context).border;

  static InputDecoration decoration(
    BuildContext context, {
    required String hint,
    String? suffix,
  }) {
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.ui(14)),
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.of(context).hint,
        fontSize: context.ui(14),
      ),
      suffixText: suffix,
      suffixStyle: TextStyle(
        color: AppColors.of(context).hint,
        fontSize: context.ui(12),
      ),
      filled: true,
      fillColor: AppColors.of(context).surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.ui(16),
        vertical: context.ui(16),
      ),
      border: border(borderColor(context)),
      enabledBorder: border(borderColor(context)),
      focusedBorder: border(AppColors.of(context).primary),
      errorBorder: border(AppColors.of(context).error),
      focusedErrorBorder: border(AppColors.of(context).error),
      errorMaxLines: 2,
      errorStyle: TextStyle(
        color: AppColors.of(context).error,
        fontSize: context.ui(12),
      ),
    );
  }
}

class PersonalizationLabel extends StatelessWidget {
  const PersonalizationLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(8)),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.of(context).navy,
          fontSize: context.ui(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PersonalizationDescription extends StatelessWidget {
  const PersonalizationDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(10)),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.of(context).hint,
          fontSize: context.ui(13),
          height: 1.4,
        ),
      ),
    );
  }
}

class PersonalizationNumberField extends StatelessWidget {
  const PersonalizationNumberField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.suffix,
    this.validator,
  });

  final String label;
  final String hint;
  final String value;
  final String? suffix;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonalizationLabel(label),
          TextFormField(
            initialValue: value,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: AppColors.of(context).navy,
              fontSize: context.ui(14),
            ),
            decoration: PersonalizationFieldStyle.decoration(
              context,
              hint: hint,
              suffix: suffix,
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class PersonalizationDateField extends StatelessWidget {
  const PersonalizationDateField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final date = value;
    final text = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonalizationLabel(label),
          TextFormField(
            key: ValueKey(value),
            initialValue: text,
            readOnly: true,
            showCursor: false,
            style: TextStyle(
              color: AppColors.of(context).navy,
              fontSize: context.ui(14),
            ),
            decoration:
                PersonalizationFieldStyle.decoration(
                  context,
                  hint: 'Pilih tanggal lahir (DD/MM/YYYY)',
                ).copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (date != null)
                        IconButton(
                          tooltip: 'Hapus tanggal lahir',
                          onPressed: () => onChanged(null),
                          icon: Icon(Icons.close_rounded, size: context.ui(24)),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.ui(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.of(context).primary,
                          size: context.ui(24),
                        ),
                      ),
                    ],
                  ),
                ),
            onTap: () async {
              FocusScope.of(context).unfocus();
              final initialDate = date == null || date.isAfter(lastDate)
                  ? lastDate
                  : date.isBefore(firstDate)
                  ? firstDate
                  : date;
              final selected = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                initialDatePickerMode: date == null
                    ? DatePickerMode.year
                    : DatePickerMode.day,
                helpText: 'Pilih tanggal lahir',
                cancelText: 'Batal',
                confirmText: 'Pilih',
              );
              if (context.mounted && selected != null) onChanged(selected);
            },
          ),
        ],
      ),
    );
  }
}

class PersonalizationDropdown extends StatelessWidget {
  const PersonalizationDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = options.contains(value) ? value : null;

    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonalizationLabel(label),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedValue),
            initialValue: selectedValue,
            isExpanded: true,
            itemHeight: context.ui(48).clamp(48.0, double.infinity).toDouble(),
            decoration: PersonalizationFieldStyle.decoration(
              context,
              hint: hint,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.of(context).hint,
              size: context.ui(24),
            ),
            style: TextStyle(
              color: AppColors.of(context).navy,
              fontSize: context.ui(14),
            ),
            dropdownColor: AppColors.of(context).surface,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class PersonalizationChoices extends StatelessWidget {
  const PersonalizationChoices({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.description,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.ui(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonalizationLabel(label),
          if (description != null) PersonalizationDescription(description!),
          Row(
            children: [
              for (var index = 0; index < options.length; index++) ...[
                if (index > 0) SizedBox(width: context.ui(8)),
                Expanded(
                  child: Semantics(
                    selected: value == options[index],
                    child: OutlinedButton(
                      onPressed: () {
                        onChanged(
                          value == options[index] ? '' : options[index],
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: value == options[index]
                            ? AppColors.of(context).primary
                            : AppColors.of(context).hint,
                        backgroundColor: value == options[index]
                            ? PersonalizationFieldStyle.softColor(context)
                            : AppColors.of(context).surface,
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.ui(4),
                          vertical: context.ui(12),
                        ),
                        side: BorderSide(
                          color: value == options[index]
                              ? AppColors.of(context).primary
                              : PersonalizationFieldStyle.borderColor(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.ui(14)),
                        ),
                      ),
                      child: Text(
                        options[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: context.ui(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
