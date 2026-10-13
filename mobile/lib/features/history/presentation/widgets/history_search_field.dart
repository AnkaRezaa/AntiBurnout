import 'package:flutter/material.dart';

class HistorySearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HistorySearchField({super.key, required this.onChanged});

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: Color(0xFFDCE6F7)),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: const InputDecoration(
        hintText: 'Cari riwayat...',
        hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B)),
        filled: true,
        fillColor: Color(0xFFEAF1FB),
        contentPadding: EdgeInsets.symmetric(vertical: 14),
        border: _border,
        enabledBorder: _border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}