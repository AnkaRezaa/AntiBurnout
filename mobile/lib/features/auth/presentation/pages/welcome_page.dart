import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _started = false;
  bool _imagesReady = false;
  bool _loadFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;

    _started = true;
    _prepareImages();
  }

  Future<void> _prepareImages() async {
    var failed = false;

    await Future.wait(
      [
        _WelcomeContent._logoAsset,
        _WelcomeContent._girlAsset,
        _WelcomeContent._leftLeafAsset,
        _WelcomeContent._rightLeafAsset,
      ].map(
        (asset) => precacheImage(
          AssetImage(asset),
          context,
          onError: (error, stackTrace) {
            failed = true;
            debugPrint('Gagal memuat aset $asset: $error');
          },
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _loadFailed = failed;
      _imagesReady = !failed;
    });
  }

  void _retry() {
    setState(() {
      _loadFailed = false;
    });

    _prepareImages();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _imagesReady
          ? const _WelcomeContent(
              key: ValueKey('welcome-content'),
            )
          : Scaffold(
              key: const ValueKey('welcome-loading'),
              backgroundColor: AppColors.background,
              body: Center(
                child: _loadFailed
                    ? TextButton(
                        onPressed: _retry,
                        child: const Text('Muat ulang gambar'),
                      )
                    : const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
              ),
            ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent({super.key});

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
            final horizontalPadding = context.ui(24);
            final verticalPadding = context.ui(20);

            final contentWidth = math.max(
              0.0,
              constraints.maxWidth - horizontalPadding * 2,
            );

            final logoWidth = math.min(
              contentWidth,
              context.ui(270),
            );

            final illustrationWidth = math.min(
              contentWidth,
              context.ui(360),
            );

            final minimumContentHeight = math.max(
              0.0,
              constraints.maxHeight - verticalPadding * 2,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: context.ui(42),
                  left: -context.ui(76),
                  child: _blob(context.ui(150)),
                ),
                Positioned(
                  top: context.ui(74),
                  right: -context.ui(84),
                  child: _blob(context.ui(160)),
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
                            // Logo.
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: context.ui(16)),
                                Image.asset(
                                  _logoAsset,
                                  width: logoWidth,
                                  height: context.ui(160),
                                  fit: BoxFit.contain,
                                  semanticLabel: 'Logo AntiBurnout',
                                ),
                                SizedBox(height: context.ui(24)),
                              ],
                            ),

                            // Ilustrasi perempuan dan tanaman.
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
                                SizedBox(height: context.ui(20)),
                              ],
                            ),

                            // Deskripsi dan tombol.
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Langkah kecil untuk kesehatan mental yang lebih baik.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.navy,
                                    fontSize: context.ui(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: context.ui(22)),
                                AppButton(
                                  label: 'Mulai Sekarang',
                                  onPressed: () {
                                    context.go(RoutePaths.login);
                                  },
                                ),
                                SizedBox(height: context.ui(24)),
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