import 'package:flutter/material.dart';

class HistoryEmptyView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const HistoryEmptyView({
    super.key,
    this.message = 'Belum ada riwayat pemeriksaan.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ],
      ),
    );
  }
}