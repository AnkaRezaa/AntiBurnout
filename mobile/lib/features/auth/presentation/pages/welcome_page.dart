import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _logoAsset = 'assets/images/LogoAntiBurnout.png';
  static const _girlAsset = 'assets/images/girl.png';
  static const _leftLeafAsset = 'assets/images/left_leaf.png';
  static const _rightLeafAsset = 'assets/images/right_leaf.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final scale = math.min(
              screenWidth / 390.0,
              screenHeight / 760.0,
            );

            final horizontalPadding = 24.0 * scale;
            final verticalPadding = 20.0 * scale;

            final contentWidth = math.max(
              0.0,
              screenWidth - horizontalPadding * 2,
            );

            final logoWidth = 270.0 * scale;
            final illustrationWidth = math.min(
              contentWidth,
              360.0 * scale,
            );

            final minimumContentHeight = math.max(
              0.0,
              screenHeight - verticalPadding * 2,
            );
            
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 42 * scale,
                  left: -76 * scale,
                  child: _blob(150 * scale),
                ),

                Positioned(
                  top: 74 * scale,
                  right: -84 * scale,
                  child: _blob(160 * scale),
                ),

                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minimumContentHeight,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 16 * scale),

                                Image.asset(
                                  _logoAsset,
                                  width: logoWidth,
                                  height: 160 * scale,
                                  fit: BoxFit.contain,
                                  semanticLabel: 'Logo AntiBurnout',
                                ),

                                SizedBox(height: 24 * scale),
                              ],
                            ),

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: illustrationWidth,
                                  child: const _WelcomeIllustration(
                                    girlAsset: _girlAsset,
                                    leftLeafAsset: _leftLeafAsset,
                                    rightLeafAsset: _rightLeafAsset,
                                  ),
                                ),

                                SizedBox(height: 20 * scale),
                              ],
                            ),

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Langkah kecil untuk\n'
                                  'kesehatan mental yang lebih baik.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.navy,
                                    fontSize: 16.0 * scale,
                                  ),
                                ),

                                SizedBox(height: 22 * scale),

                                AppButton(
                                  label: 'Mulai Sekarang',
                                  scale: scale,
                                  onPressed: () {
                                    context.go(RoutePaths.register);
                                  },
                                ),

                                SizedBox(height: 24 * scale),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _blob(double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.blob,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({
    required this.girlAsset,
    required this.leftLeafAsset,
    required this.rightLeafAsset,
  });

  final String girlAsset;
  final String leftLeafAsset;
  final String rightLeafAsset;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final leafWidth = width * 0.19;
          final leafHeight = height * 0.46;
          final leafBottom = height * 0.04;
          final girlPadding = width * 0.08;

          // Widget ini hanya menampilkan perempuan dan tanaman.
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                bottom: leafBottom,
                child: Image.asset(
                  leftLeafAsset,
                  width: leafWidth,
                  height: leafHeight,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),

              Positioned(
                right: 0,
                bottom: leafBottom,
                child: Image.asset(
                  rightLeafAsset,
                  width: leafWidth,
                  height: leafHeight,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),

              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: girlPadding,
                  ),
                  child: Image.asset(
                    girlAsset,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    semanticLabel: 'Perempuan sedang bermeditasi',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}