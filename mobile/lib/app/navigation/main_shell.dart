import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

/// Each branch owns its Navigator and keeps its pages mounted for the session.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    this.onBranchSelected,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int>? onBranchSelected;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            border: Border(
              top: BorderSide(color: AppColors.of(context).border),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            // Re-selecting a tab also preserves its current navigation stack.
            onTap: (index) {
              onBranchSelected?.call(index);
              navigationShell.goBranch(index);
            },
            backgroundColor: AppColors.of(context).surface,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.of(context).primary,
            unselectedItemColor: AppColors.of(context).body,
            selectedFontSize: context.ui(12),
            unselectedFontSize: context.ui(12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                label: 'Survei',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pending_actions_outlined),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
