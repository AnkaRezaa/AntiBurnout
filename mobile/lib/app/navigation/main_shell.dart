import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_navigation_bar.dart';

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
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          // Re-selecting a tab also preserves its current navigation stack.
          onTap: (index) {
            onBranchSelected?.call(index);
            navigationShell.goBranch(index);
          },
        ),
      ),
    );
  }
}
