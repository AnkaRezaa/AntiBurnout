import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_blob_background.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/survey_question.dart';
import '../controllers/survey_state.dart';

/// The survey UI from main, backed by the existing per-origin session state.
class SurveyStepper extends StatefulWidget {
  const SurveyStepper({
    super.key,
    required this.state,
    required this.onBack,
    required this.onChanged,
    required this.onSubmit,
  });

  final SurveyState state;
  final VoidCallback onBack;
  final void Function(String id, String answer) onChanged;
  final Future<void> Function() onSubmit;

  @override
  State<SurveyStepper> createState() => _SurveyStepperState();
}

class _SurveyStepperState extends State<SurveyStepper> {
  int _step = 0;

  int get _total => widget.state.questions.length + 1;
  bool get _isReview => _step >= widget.state.questions.length;
  SurveyQuestion get _question => widget.state.questions[_step];
  bool get _canContinue => _isReview
      ? widget.state.canSubmit
      : _question.isValidAnswer(widget.state.answers[_question.id]);

  void _back() {
    if (widget.state.isSubmitting) return;
    if (_step == 0) {
      widget.onBack();
    } else {
      setState(() => _step--);
    }
  }

  void _next() {
    if (widget.state.isSubmitting || !_canContinue) return;
    if (_isReview) {
      widget.onSubmit();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _total;
    final title = _isReview ? 'Periksa jawabanmu' : _question.label;
    final subtitle = _isReview
        ? 'Pastikan jawaban sesuai sebelum dikirim.'
        : _question.subtitle;
    final tip = _isReview
        ? 'Hasil merupakan estimasi risiko, bukan diagnosis.'
        : _question.tip;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: AppBlobBackground(
          subtle: true,
          refreshKey: _step,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                key: PageStorageKey('survey-step-$_step'),
                padding: EdgeInsets.only(bottom: context.ui(AppSpacing.lg)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        (constraints.maxHeight - context.ui(AppSpacing.lg))
                            .clamp(0.0, double.infinity)
                            .toDouble(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Keep the title anchored to progress on every step.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppPageHeader(
                            tooltip: _step == 0
                                ? 'Kembali ke pengantar survei'
                                : 'Kembali',
                            onBack: widget.state.isSubmitting ? null : _back,
                          ),
                          SizedBox(height: context.ui(AppSpacing.lg)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.ui(AppSpacing.lg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Langkah ${_step + 1} dari $_total',
                                  style: _subtitleStyle(context, 13).copyWith(
                                    color: AppColors.of(context).navy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: context.ui(12)),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    context.ui(AppSpacing.radius),
                                  ),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: context.ui(9),
                                    color: AppColors.of(context).primary,
                                    backgroundColor: AppColors.of(context).blob,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: context.ui(AppSpacing.sm),
                                    ),
                                    child: Text(
                                      '${(progress * 100).round()}%',
                                      style: AppTextStyles.link(context)
                                          .copyWith(fontSize: context.ui(12)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: context.ui(AppSpacing.md),
                                    bottom: context.ui(
                                      AppSpacing.xl + AppSpacing.md,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.title(context)
                                            .copyWith(fontSize: context.ui(23)),
                                      ),
                                      SizedBox(height: context.ui(12)),
                                      Text(
                                        subtitle,
                                        style: _subtitleStyle(context, 13),
                                      ),
                                      SizedBox(
                                        height: context.ui(AppSpacing.xl),
                                      ),
                                      IgnorePointer(
                                        ignoring: widget.state.isSubmitting,
                                        child: _isReview
                                            ? _review(context)
                                            : _input(context, _question),
                                      ),
                                      if (widget.state.errorMessage !=
                                          null) ...[
                                        SizedBox(
                                          height: context.ui(AppSpacing.lg),
                                        ),
                                        Semantics(
                                          liveRegion: true,
                                          child: Text(
                                            widget.state.errorMessage!,
                                            style: _subtitleStyle(context, 13)
                                                .copyWith(
                                                  color: AppColors.of(context)
                                                      .error,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.ui(AppSpacing.lg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _actions(context),
                            SizedBox(height: context.ui(AppSpacing.lg)),
                            _TipCard(text: tip),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final back = OutlinedButton.icon(
      onPressed: widget.state.isSubmitting ? null : _back,
      icon: Icon(Icons.chevron_left_rounded, size: context.ui(24)),
      label: const Text('Kembali'),
      style: _backStyle(context),
    );
    final next = AppButton(
      label: _isReview ? 'Kirim & lihat hasil' : 'Lanjut',
      isLoading: widget.state.isSubmitting,
      onPressed: _canContinue ? _next : null,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < context.ui(300) ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              back,
              SizedBox(height: context.ui(10)),
              next,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: back),
            SizedBox(width: context.ui(10)),
            Expanded(child: next),
          ],
        );
      },
    );
  }

  double _value(SurveyQuestion question) {
    final value = double.tryParse(widget.state.answers[question.id] ?? '');
    if (value == null || !value.isFinite) return 0;
    return value.clamp(0.0, question.maximum).toDouble();
  }

  void _number(SurveyQuestion question, double value) {
    final clamped = value.clamp(0.0, question.maximum);
    widget.onChanged(
      question.id,
      question.inputKind == SurveyInputKind.duration
          ? clamped.toStringAsFixed(1)
          : clamped.round().toString(),
    );
  }

  Widget _input(BuildContext context, SurveyQuestion question) {
    final value = _value(question);
    switch (question.inputKind) {
      case SurveyInputKind.choice:
        const activityDetails = [
          'Aktivitas terasa mudah dihadapi',
          'Terasa terbebani, tetapi masih teratasi',
          'Beban terasa sulit dihadapi',
        ];
        return Column(
          children: [
            for (final (index, option) in question.options.indexed)
              Padding(
                padding: EdgeInsets.only(bottom: context.ui(10)),
                child: _ChoiceTile(
                  label: option,
                  detail:
                      question.id == 'activity_load' &&
                          index < activityDetails.length
                      ? activityDetails[index]
                      : null,
                  selected: widget.state.answers[question.id] == option,
                  onTap: () => widget.onChanged(question.id, option),
                ),
              ),
          ],
        );
      case SurveyInputKind.duration:
        return Column(
          children: [
            Text(value.toStringAsFixed(1), style: _numberStyle(context, 36)),
            Text(question.unit, style: _subtitleStyle(context, 13)),
            _CleanSlider(
              value: value,
              maximum: question.maximum,
              onChanged: (value) => _number(question, value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 jam', style: _subtitleStyle(context, 12)),
                Text(
                  '${question.maximum.round()} jam',
                  style: _subtitleStyle(context, 12),
                ),
              ],
            ),
            SizedBox(height: context.ui(10)),
            Row(
              children: [
                _SquareButton(
                  icon: Icons.remove_rounded,
                  onPressed: value <= 0
                      ? null
                      : () => _number(question, value - .5),
                ),
                SizedBox(width: context.ui(10)),
                Expanded(child: _ValueBox(value: value)),
                SizedBox(width: context.ui(10)),
                _SquareButton(
                  icon: Icons.add_rounded,
                  onPressed: value >= question.maximum
                      ? null
                      : () => _number(question, value + .5),
                ),
              ],
            ),
          ],
        );
      case SurveyInputKind.counter:
        return Column(
          children: [
            SizedBox(height: context.ui(12)),
            Text(value.round().toString(), style: _numberStyle(context, 52)),
            Text(question.unit, style: _subtitleStyle(context, 13)),
            SizedBox(height: context.ui(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SquareButton(
                  icon: Icons.remove_rounded,
                  onPressed: value <= 0
                      ? null
                      : () => _number(question, value - 1),
                ),
                _SquareButton(
                  icon: Icons.add_rounded,
                  onPressed: () => _number(question, value + 1),
                ),
              ],
            ),
          ],
        );
      case SurveyInputKind.minutes:
        return Column(
          children: [
            Text(value.round().toString(), style: _numberStyle(context, 46)),
            Text(question.unit, style: _subtitleStyle(context, 13)),
            SizedBox(height: context.ui(18)),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = context.ui(8);
                final columns =
                    constraints.maxWidth < context.ui(280) ||
                        MediaQuery.textScalerOf(context).scale(14) > 20
                    ? 2
                    : 4;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final minutes in [0, 5, 10, 15])
                      SizedBox(
                        width: width,
                        child: FilledButton(
                          onPressed: () =>
                              _number(question, minutes.toDouble()),
                          style: FilledButton.styleFrom(
                            backgroundColor: value == minutes
                                ? AppColors.of(context).primary
                                : Color.alphaBlend(
                                    AppColors.of(context).blob
                                        .withValues(alpha: .7),
                                    AppColors.of(context).background,
                                  ),
                            foregroundColor: value == minutes
                                ? AppColors.of(context).onPrimary
                                : AppColors.of(context).primary,
                            minimumSize: Size(
                              context.ui(64),
                              context.ui(48).clamp(48.0, double.infinity),
                            ),
                            textStyle: _subtitleStyle(
                              context,
                              14,
                            ).copyWith(fontWeight: FontWeight.w700),
                            padding: EdgeInsets.all(context.ui(12)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.ui(10),
                              ),
                            ),
                          ),
                          child: Text(minutes.toString()),
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: context.ui(16)),
            _SurveyAnswerField(
              key: ValueKey(question.id),
              question: question,
              answer: widget.state.answers[question.id] ?? '',
              onChanged: (answer) => widget.onChanged(question.id, answer),
            ),
          ],
        );
      case SurveyInputKind.rating:
        return Column(
          children: [
            Text(value.round().toString(), style: _numberStyle(context, 46)),
            Text('dari 100', style: _subtitleStyle(context, 13)),
            SizedBox(height: context.ui(18)),
            _CleanSlider(
              value: value,
              maximum: question.maximum,
              onChanged: (value) => _number(question, value),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sangat tidak nyaman',
                    style: _subtitleStyle(context, 10),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sangat nyaman',
                    textAlign: TextAlign.end,
                    style: _subtitleStyle(context, 10),
                  ),
                ),
              ],
            ),
          ],
        );
      case SurveyInputKind.text:
        return _SurveyAnswerField(
          key: ValueKey(question.id),
          question: question,
          answer: widget.state.answers[question.id] ?? '',
          onChanged: (answer) => widget.onChanged(question.id, answer),
        );
    }
  }

  IconData _reviewIcon(String id) => switch (id) {
    'sleep_quality' => Icons.nights_stay_outlined,
    'screen_hours' => Icons.desktop_windows_outlined,
    'sleep_hours' => Icons.bed_outlined,
    'coffee_cups' => Icons.coffee_outlined,
    'activity_load' => Icons.sentiment_satisfied_alt_outlined,
    'meditation_minutes' => Icons.self_improvement_outlined,
    'mood_rating' => Icons.mood_outlined,
    _ => Icons.assignment_outlined,
  };

  Widget _review(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.of(context).surface,
      border: Border.all(color: AppColors.of(context).border),
      borderRadius: BorderRadius.circular(context.ui(AppSpacing.radius)),
    ),
    child: Column(
      children: [
        for (final (index, question) in widget.state.questions.indexed)
          InkWell(
            onTap: () => setState(() => _step = index),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.ui(12),
                vertical: context.ui(11),
              ),
              decoration: BoxDecoration(
                border: index == widget.state.questions.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(color: AppColors.of(context).border),
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    _reviewIcon(question.id),
                    size: context.ui(19),
                    color: AppColors.of(context).navy,
                  ),
                  SizedBox(width: context.ui(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${question.reviewLabel.isEmpty ? question.label : question.reviewLabel}:',
                          style: _subtitleStyle(context, 12),
                        ),
                        Text(
                          '${widget.state.answers[question.id] ?? '—'} ${question.unit}'
                              .trim(),
                          style: _subtitleStyle(context, 12).copyWith(
                            color: AppColors.of(context).navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _step = index),
                    style: TextButton.styleFrom(
                      textStyle: _subtitleStyle(context, 14),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.ui(12),
                        vertical: context.ui(8),
                      ),
                    ),
                    child: const Text('Ubah'),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.of(context).primary,
                    size: context.ui(18),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _SurveyAnswerField extends StatefulWidget {
  const _SurveyAnswerField({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String answer;
  final ValueChanged<String> onChanged;

  @override
  State<_SurveyAnswerField> createState() => _SurveyAnswerFieldState();
}

class _SurveyAnswerFieldState extends State<_SurveyAnswerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
  }

  @override
  void didUpdateWidget(covariant _SurveyAnswerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.answer) {
      _controller.value = TextEditingValue(
        text: widget.answer,
        selection: TextSelection.collapsed(offset: widget.answer.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.question.inputKind == SurveyInputKind.minutes;
    return TextFormField(
      key: ValueKey('survey-answer-${widget.question.id}'),
      controller: _controller,
      keyboardType: minutes ? TextInputType.number : TextInputType.multiline,
      minLines: 1,
      maxLines: minutes ? 1 : 5,
      style: _subtitleStyle(context, 14),
      decoration: InputDecoration(
        hintText: minutes ? 'Atau isi durasi sendiri' : 'Tulis jawabanmu',
        suffixText: minutes ? 'menit' : null,
        hintStyle: _subtitleStyle(
          context,
          14,
        ).copyWith(color: AppColors.of(context).hint),
        suffixStyle: _subtitleStyle(context, 14),
        errorStyle: _subtitleStyle(context, 12),
        contentPadding: EdgeInsets.all(context.ui(16)),
      ),
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: minutes
          ? (answer) => widget.question.isValidAnswer(answer)
                ? null
                : 'Masukkan jumlah menit berupa bilangan bulat 0 atau lebih.'
          : null,
    );
  }
}

ButtonStyle _backStyle(BuildContext context) => OutlinedButton.styleFrom(
  foregroundColor: AppColors.of(context).navy,
  side: BorderSide(color: AppColors.of(context).border),
  minimumSize: Size(0, context.ui(52)),
  textStyle: _subtitleStyle(context, 16).copyWith(fontWeight: FontWeight.w700),
  padding: EdgeInsets.symmetric(
    horizontal: context.ui(16),
    vertical: context.ui(14),
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
  ),
);
TextStyle _subtitleStyle(BuildContext context, double size) =>
    AppTextStyles.subtitle(context).copyWith(fontSize: context.ui(size));
TextStyle _numberStyle(BuildContext context, double size) =>
    AppTextStyles.title(context).copyWith(
      color: AppColors.of(context).primary,
      fontSize: context.ui(size),
    );

class _CleanSlider extends StatelessWidget {
  const _CleanSlider({
    required this.value,
    required this.maximum,
    required this.onChanged,
  });
  final double value, maximum;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => SliderTheme(
    data: SliderTheme.of(context).copyWith(
      trackHeight: context.ui(6),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: context.ui(9)),
      overlayShape: RoundSliderOverlayShape(overlayRadius: context.ui(18)),
    ),
    child: Slider(
      value: value,
      min: 0,
      max: maximum,
      activeColor: AppColors.of(context).primary,
      inactiveColor: AppColors.of(context).blob,
      onChanged: (v) => onChanged((v * 2).round() / 2),
    ),
  );
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      minHeight: context.ui(48).clamp(48.0, double.infinity),
    ),
    padding: EdgeInsets.all(context.ui(8)),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.of(context).border),
      borderRadius: BorderRadius.circular(context.ui(12)),
    ),
    child: RichText(
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(
        style: _subtitleStyle(context, 14).copyWith(
          color: AppColors.of(context).navy,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: value.toStringAsFixed(1)),
          TextSpan(
            text: ' jam',
            style: TextStyle(
              color: AppColors.of(context).body,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });
  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? Color.alphaBlend(
            AppColors.of(context).blob.withValues(alpha: .55),
            AppColors.of(context).background,
          )
        : AppColors.of(context).surface,
    borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
      child: Container(
        constraints: BoxConstraints(
          minHeight: context.ui(detail == null ? 56 : 64),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.ui(12),
          vertical: context.ui(8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            context.ui(AppSpacing.fieldRadius),
          ),
          border: Border.all(
            color: selected
                ? AppColors.of(context).primary
                : AppColors.of(context).border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.of(context).primary
                  : AppColors.of(context).hint,
              size: context.ui(21),
            ),
            SizedBox(width: context.ui(12)),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: _subtitleStyle(context, 13).copyWith(
                      color: AppColors.of(context).navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (detail != null) ...[
                    SizedBox(height: context.ui(3)),
                    Text(detail!, style: _subtitleStyle(context, 10)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.ui(48).clamp(48.0, double.infinity),
    height: context.ui(48).clamp(48.0, double.infinity),
    child: IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Color.alphaBlend(
          AppColors.of(context).blob.withValues(alpha: .6),
          AppColors.of(context).background,
        ),
        foregroundColor: AppColors.of(context).primary,
        disabledForegroundColor: AppColors.of(context).hint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.ui(12)),
        ),
      ),
      icon: Icon(icon, size: context.ui(22)),
    ),
  );
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.ui(14)),
    decoration: BoxDecoration(
      color: Color.alphaBlend(
        AppColors.of(context).blob.withValues(alpha: .65),
        AppColors.of(context).background,
      ),
      borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.lightbulb_outline_rounded,
          color: AppColors.of(context).primary,
          size: context.ui(22),
        ),
        SizedBox(width: context.ui(10)),
        Expanded(child: Text(text, style: _subtitleStyle(context, 12))),
      ],
    ),
  );
}
