//button bawah

import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/survey/presentation/pages/survey_intro_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/results/presentation/pages/result_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;


     @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        onStartSurvey: () => setState(() => _currentIndex = 1),
        onViewHistory: () => setState(() => _currentIndex = 3),
        onViewResult: () => setState(() => _currentIndex = 2),
      ),
      const SurveyIntroPage(),
      const ResultPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Survei',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Hasil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_rounded),
              activeIcon: Icon(Icons.schedule_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
