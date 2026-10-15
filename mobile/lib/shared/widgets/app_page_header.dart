import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_back_button.dart';

/// Aligns page titles with the Dashboard greeting and back/title pairs with
/// Personalization, while keeping the back button's full touch target visible.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    this.title,
    this.onBack,
    this.showBackButton = true,
    this.tooltip = 'Kembali',
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
  });

  final String? title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final String tooltip;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final margin = context.ui(24);
    final top = context.ui(28);
    final titleWidget = title == null
        ? null
        : Text(
            title!,
            style: AppTextStyles.title(
              context,
            ).copyWith(fontSize: context.ui(fontSize), fontWeight: fontWeight),
          );

    Widget content;
    if (!showBackButton) {
      content = Padding(
        padding: EdgeInsets.fromLTRB(margin, top, margin, 0),
        child: titleWidget,
      );
    } else {
      final touchSize = math.max(48.0, context.ui(40));
      final iconInset = (touchSize - context.ui(28)) / 2;

      content = Padding(
        padding: EdgeInsets.fromLTRB(
          margin - context.ui(6) - iconInset,
          top - iconInset,
          margin,
          0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: touchSize),
          child: Stack(
            children: [
              if (titleWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: iconInset + context.ui(36),
                    top: iconInset,
                  ),
                  child: titleWidget,
                )
              else
                SizedBox(height: touchSize, width: double.infinity),
              Positioned(
                left: 0,
                top: 0,
                width: touchSize,
                height: touchSize,
                child: AppBackButton(onPressed: onBack, tooltip: tooltip),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        // Dashboard caps its content at 720, excluding the page margins.
        constraints: BoxConstraints(maxWidth: 720 + margin * 2),
        child: SizedBox(width: double.infinity, child: content),
      ),
    );
  }
}
