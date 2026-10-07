import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.subtitle = 'Jaga kesehatan mentalmu, mulai dari sekarang.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo,',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$userName!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A8A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
