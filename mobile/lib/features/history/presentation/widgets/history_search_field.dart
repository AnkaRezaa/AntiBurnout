import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistorySearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HistorySearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: colors.border),
    );
    return TextField(
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: colors.body),
      decoration: InputDecoration(
        hintText: 'Cari riwayat...',
        hintStyle: TextStyle(fontSize: 14, color: colors.hint),
        prefixIcon: Icon(Icons.search_rounded, color: colors.body),
        filled: true,
        fillColor: colors.blob,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}
