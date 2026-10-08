import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';

class PersonalizationFieldStyle {
  static const softColor = Color(0xFFEEF0FF);
  static const borderColor = Color(0xFFD8DFFF);

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
        color: AppColors.hint,
        fontSize: context.ui(14),
      ),
      suffixText: suffix,
      suffixStyle: TextStyle(
        color: AppColors.hint,
        fontSize: context.ui(12),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.ui(16),
        vertical: context.ui(16),
      ),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
      errorMaxLines: 2,
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
          color: AppColors.navy,
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
          color: AppColors.hint,
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              color: AppColors.navy,
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
            decoration: PersonalizationFieldStyle.decoration(
              context,
              hint: hint,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.hint,
              size: context.ui(24),
            ),
            style: TextStyle(
              color: AppColors.navy,
              fontSize: context.ui(14),
            ),
            dropdownColor: Colors.white,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
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
          if (description != null)
            PersonalizationDescription(description!),
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
                            ? AppColors.primary
                            : AppColors.hint,
                        backgroundColor: value == options[index]
                            ? PersonalizationFieldStyle.softColor
                            : Colors.white,
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.ui(4),
                          vertical: context.ui(12),
                        ),
                        side: BorderSide(
                          color: value == options[index]
                              ? AppColors.primary
                              : PersonalizationFieldStyle.borderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.ui(14),
                          ),
                        ),
                      ),
                      child: Text(
                        options[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.ui(12),
                        ),
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