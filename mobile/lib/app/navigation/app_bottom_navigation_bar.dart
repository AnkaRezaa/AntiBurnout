import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

/// Scales the whole bar with its available width, keeping short screens compact.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Unlike page content, a wide bar needs to grow even when only
            // the window width changes. Keep the phone size as a usable minimum.
            final scale = MediaQuery.sizeOf(context).height < 600
                ? 1.0
                : (constraints.maxWidth / AppScale.designWidth)
                      .clamp(1.0, AppScale.maximumScale)
                      .toDouble();
            // BottomNavigationBar clamps inherited text scaling internally.
            final fontSize = MediaQuery.textScalerOf(context)
                .clamp(maxScaleFactor: 1.5)
                .scale(12 * scale);
            return ConstrainedBox(
              constraints: BoxConstraints(
                // Flutter adds the bottom system inset inside the bar itself.
                minHeight:
                    kBottomNavigationBarHeight * scale +
                    MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                backgroundColor: colors.surface,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.body,
                iconSize: 24 * scale,
                selectedFontSize: fontSize,
                unselectedFontSize: fontSize,
                selectedLabelStyle: const TextStyle(height: 1.2),
                unselectedLabelStyle: const TextStyle(height: 1.2),
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
            );
          },
        ),
      ),
    );
  }
}
