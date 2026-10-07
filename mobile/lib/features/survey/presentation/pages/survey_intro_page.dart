import 'package:flutter/material.dart';

class SurveyIntroPage extends StatelessWidget {
  const SurveyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Text(
            'Halaman Survei Burnout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}
