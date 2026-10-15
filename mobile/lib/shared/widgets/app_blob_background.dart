import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

/// Decorative circles behind the page, independent of its form and scroll state.
/// A visit, refresh, or new [refreshKey] generates a fresh arrangement; ordinary
/// rebuilds keep it still so typing and scrolling do not move the background.
class AppBlobBackground extends StatefulWidget {
  const AppBlobBackground({
    super.key,
    required this.child,
    this.subtle = false,
    this.refreshKey,
  });

  final Widget child;
  final bool subtle;
  final Object? refreshKey;

  @override
  State<AppBlobBackground> createState() => _AppBlobBackgroundState();
}

class _AppBlobBackgroundState extends State<AppBlobBackground> {
  final _random = math.Random();
  late List<_Blob> _blobs;
  bool? _wasActive;

  List<_Blob> _generate() {
    final edges = [0, 1, 2, 3]..shuffle(_random);
    final interiorCount = _random.nextBool() ? 1 : 2;
    return [
      // Keep at least one full circle inside the page, with occasional pairs.
      // Subtle pages also retain one interior circle when drawing only two.
      for (var index = 0; index < interiorCount; index++)
        _Blob(
          position: Offset(
            0.3 + _random.nextDouble() * 0.4,
            interiorCount == 1
                ? 0.25 + _random.nextDouble() * 0.5
                : 0.23 + index * 0.34 + _random.nextDouble() * 0.2,
          ),
          diameter: 140 + _random.nextDouble() * 80,
        ),
      for (final edge in edges.take(3 - interiorCount))
        _Blob(
          edge: edge,
          position: Offset(
            0.15 + _random.nextDouble() * 0.7,
            0.15 + _random.nextDouble() * 0.7,
          ),
          diameter: 140 + _random.nextDouble() * 80,
          overhang: 0.1 + _random.nextDouble() * 0.25,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _blobs = _generate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Indexed tab navigation keeps pages alive. Re-entering one should refresh
    // only its decoration, leaving the cached navigation stack and draft alone.
    final active =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (active && _wasActive == false) _blobs = _generate();
    _wasActive = active;
  }

  @override
  void didUpdateWidget(covariant AppBlobBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _blobs = _generate();
  }

  @override
  void reassemble() {
    super.reassemble();
    _blobs = _generate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: const ValueKey('app-blob-paint'),
                    painter: _BlobPainter(
                      blobs: _blobs,
                      scale: AppScale.factor(context),
                      safeInsets: MediaQuery.paddingOf(context),
                      subtle: widget.subtle,
                      baseColor: colors.blob,
                      accentColor: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Blob {
  const _Blob({
    this.edge,
    required this.position,
    required this.diameter,
    this.overhang = 0,
  });

  final int? edge;
  final Offset position;
  final double diameter;
  final double overhang;
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({
    required this.blobs,
    required this.scale,
    required this.safeInsets,
    required this.subtle,
    required this.baseColor,
    required this.accentColor,
  });

  final List<_Blob> blobs;
  final double scale;
  final EdgeInsets safeInsets;
  final bool subtle;
  final Color baseColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final safeHeight = size.height - safeInsets.vertical;
    if (size.isEmpty || safeHeight <= 0) return;

    // The Scaffold body already ends above the app navbar. Keep the whole
    // circle inside its vertical safe area, rather than cutting it at a bar.
    final gap = math.min(12 * scale, safeHeight / 4);
    final maxDiameter = math.min(size.shortestSide * 0.6, safeHeight - gap * 2);
    final paint = Paint();
    for (final (index, blob) in blobs.take(subtle ? 2 : 3).indexed) {
      final diameter = math.min(blob.diameter * scale, maxDiameter);
      final radius = diameter / 2;
      final outside = radius * blob.overhang;
      final minCenterY = safeInsets.top + gap + radius;
      final maxCenterY = math.max(
        minCenterY,
        size.height - safeInsets.bottom - gap - radius,
      );
      final centerY = (size.height * blob.position.dy)
          .clamp(minCenterY, maxCenterY)
          .toDouble();
      final center = switch (blob.edge) {
        0 => Offset(size.width * blob.position.dx, minCenterY),
        1 => Offset(size.width + outside, centerY),
        2 => Offset(size.width * blob.position.dx, maxCenterY),
        3 => Offset(-outside, centerY),
        _ => Offset(
          (size.width * blob.position.dx)
              .clamp(radius, size.width - radius)
              .toDouble(),
          centerY,
        ),
      };
      paint.color = index.isEven
          ? baseColor.withValues(alpha: subtle ? 0.4 : 0.9)
          : accentColor.withValues(alpha: subtle ? 0.035 : 0.075);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      !identical(blobs, oldDelegate.blobs) ||
      scale != oldDelegate.scale ||
      safeInsets != oldDelegate.safeInsets ||
      subtle != oldDelegate.subtle ||
      baseColor != oldDelegate.baseColor ||
      accentColor != oldDelegate.accentColor;
}
