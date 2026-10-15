import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';

class HistorySearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HistorySearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.ui(16)),
      borderSide: BorderSide(color: colors.border),
    );
    return TextField(
      onChanged: onChanged,
      style: TextStyle(fontSize: context.ui(14), color: colors.body),
      decoration: InputDecoration(
        hintText: 'Cari riwayat...',
        hintStyle: TextStyle(fontSize: context.ui(14), color: colors.hint),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.body,
          size: context.ui(24),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: context.ui(48).clamp(48.0, double.infinity).toDouble(),
          minHeight: context.ui(48).clamp(48.0, double.infinity).toDouble(),
        ),
        filled: true,
        fillColor: colors.blob,
        contentPadding: EdgeInsets.symmetric(vertical: context.ui(14)),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.ui(16)),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}
