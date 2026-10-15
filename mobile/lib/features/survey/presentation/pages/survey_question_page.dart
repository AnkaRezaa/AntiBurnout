import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SurveyQuestionPage extends StatefulWidget {
  const SurveyQuestionPage({super.key, this.onBack, this.onViewResult});
  final VoidCallback? onBack;
  final VoidCallback? onViewResult;
  @override
  State<SurveyQuestionPage> createState() => _SurveyQuestionPageState();
}

class _SurveyQuestionPageState extends State<SurveyQuestionPage> {
  int _step = 1;
  String? _sleep;
  String _load = 'Sedang';
  double _screen = 6, _sleepHours = 7, _rating = 65;
  int _coffee = 2, _meditation = 10;

  void _back() {
    if (_step == 1) return widget.onBack?.call();
    setState(() => _step--);
  }

  void _next() {
    if (_step == 1 && _sleep == null) return;
    if (_step < 8) return setState(() => _step++);
    widget.onViewResult?.call();
  }

  String get _title => [
    'Bagaimana kualitas tidurmu\ntadi malam?',
    'Berapa lama kamu menggunakan\nlayar hari ini?',
    'Berapa lama durasi tidur Anda\nhari ini?',
    'Berapa cangkir kopi yang kamu\nminum hari ini?',
    'Seberapa terbebani kamu oleh\naktivitas hari ini?',
    'Berapa menit kamu melakukan\nmeditasi hari ini?',
    'Berapa rating secara keseluruhan\nhari ini?',
    'Periksa jawabanmu',
  ][_step - 1];
  String get _subtitle => [
    'Pilih kualitas tidur yang paling sesuai.',
    'Hitung penggunaan HP, laptop, dan TV.',
    'Geser slider atau gunakan tombol untuk menentukan durasi tidur.',
    'Gunakan tombol untuk menambah atau mengurangi jumlah.',
    'Pilih kondisi yang paling mendekati perasaanmu.',
    'Pilih durasi atau isi dengan angka sendiri.',
    'Geser slider untuk menentukan nilai.',
    'Pastikan jawaban sesuai sebelum dikirim.',
  ][_step - 1];
  String get _tip => [
    'Durasi dan kualitas tidur adalah dua hal berbeda.',
    'Beri jeda dari layar untuk mengistirahatkan mata dan pikiran.',
    'Tidur yang cukup membantu menjaga kesehatan mental dan produktivitasmu.',
    'Kafein secukupnya memberi energi, namun berlebihan bisa memicu kecemasan.',
    'Menyeimbangkan aktivitas harian sangat penting untuk kesehatan fisik dan mentalmu.',
    'Cuma butuh 15 menit meditasi buat recharge energi dan jernihin pikiran.',
    'Refleksi singkat di akhir hari membantu mengenali apa yang membuatmu stres atau bahagia.',
    'Hasil merupakan estimasi risiko, bukan diagnosis.',
  ][_step - 1];

  @override
  Widget build(BuildContext context) {
    final progress = _step / 8;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -context.ui(72),
              left: -context.ui(64),
              child: IgnorePointer(
                child: Container(
                  width: context.ui(150),
                  height: context.ui(150),
                  decoration: const BoxDecoration(
                    color: AppColors.blob,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.ui(24),
                context.ui(16),
                context.ui(24),
                context.ui(24),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _back,
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.navy,
                            size: context.ui(28),
                          ),
                        ),
                      ),
                      SizedBox(height: context.ui(22)),
                      Text(
                        'Langkah $_step dari 8',
                        style: _subtitleStyle(context, 13).copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.ui(10)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.ui(16)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: context.ui(9),
                          color: AppColors.primary,
                          backgroundColor: AppColors.blob,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: context.ui(7)),
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: AppTextStyles.link.copyWith(
                              fontSize: context.ui(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.ui(12)),
                      Text(
                        _title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: context.ui(23),
                          color: const Color(0xFF18357A),
                        ),
                      ),
                      SizedBox(height: context.ui(8)),
                      Text(_subtitle, style: _subtitleStyle(context, 13)),
                      SizedBox(height: context.ui(18)),
                      _input(context),
                      SizedBox(height: context.ui(24)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _back,
                              icon: const Icon(Icons.chevron_left_rounded),
                              label: const Text('Kembali'),
                              style: _backStyle(context),
                            ),
                          ),
                          SizedBox(width: context.ui(10)),
                          Expanded(
                            child: FilledButton(
                              onPressed: _step == 1 && _sleep == null
                                  ? null
                                  : _next,
                              style: _nextStyle(context),
                              child: Text(
                                _step == 8 ? 'Kirim & lihat hasil' : 'Lanjut',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: context.ui(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.ui(14)),
                      _TipCard(text: _tip),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(BuildContext context) {
    if (_step == 1) {
      return _options(
        context,
        ['Buruk', 'Cukup', 'Baik', 'Sangat baik'],
        _sleep,
        (v) => setState(() => _sleep = v),
      );
    }
    if (_step == 2) {
      return _duration(
        context,
        _screen,
        24,
        '0 jam',
        '24 jam',
        (v) => setState(() => _screen = v),
      );
    }
    if (_step == 3) {
      return _duration(
        context,
        _sleepHours,
        10,
        '0 jam',
        '10 jam',
        (v) => setState(() => _sleepHours = v),
      );
    }
    if (_step == 4) {
      return _counter(context);
    }
    if (_step == 5) {
      return _options(
        context,
        ['Ringan', 'Sedang', 'Berat'],
        _load,
        (v) => setState(() => _load = v),
        details: [
          'Aktivitas terasa mudah dihadapi',
          'Terasa terbebani, tetapi masih teratasi',
          'Beban terasa sulit dihadapi',
        ],
      );
    }
    if (_step == 6) return _meditationInput(context);
    if (_step == 7) return _ratingInput(context);
    return _review(context);
  }

  Widget _review(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(context.ui(AppSpacing.radius)),
    ),
    child: Column(
      children: [
        _reviewRow(
          context,
          Icons.nights_stay_outlined,
          'Kualitas tidur',
          _sleep ?? '- ',
          1,
        ),
        _reviewRow(
          context,
          Icons.desktop_windows_outlined,
          'Waktu layar',
          '${_screen.toStringAsFixed(0)} jam',
          2,
        ),
        _reviewRow(
          context,
          Icons.bed_outlined,
          'Durasi tidur',
          '${_sleepHours.toStringAsFixed(0)} jam',
          3,
        ),
        _reviewRow(
          context,
          Icons.coffee_outlined,
          'Kopi',
          '$_coffee cangkir',
          4,
        ),
        _reviewRow(
          context,
          Icons.sentiment_satisfied_alt_outlined,
          'Stres',
          _load,
          5,
        ),
        _reviewRow(
          context,
          Icons.self_improvement_outlined,
          'Meditasi',
          '$_meditation menit',
          6,
        ),
        _reviewRow(
          context,
          Icons.mood_outlined,
          'Suasana hati',
          '${_rating.round()}/100',
          7,
          isLast: true,
        ),
      ],
    ),
  );

  Widget _reviewRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    int step, {
    bool isLast = false,
  }) => InkWell(
    onTap: () => setState(() => _step = step),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.ui(12),
        vertical: context.ui(11),
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: context.ui(19), color: AppColors.navy),
          SizedBox(width: context.ui(12)),
          Expanded(child: Text('$label:', style: _subtitleStyle(context, 12))),
          Text(
            value,
            style: _subtitleStyle(
              context,
              12,
            ).copyWith(color: AppColors.navy, fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: () => setState(() => _step = step),
            child: const Text('Ubah'),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: context.ui(18),
          ),
        ],
      ),
    ),
  );

  Widget _options(
    BuildContext context,
    List<String> options,
    String? selected,
    ValueChanged<String> onChanged, {
    List<String>? details,
  }) => Column(
    children: List.generate(
      options.length,
      (i) => Padding(
        padding: EdgeInsets.only(bottom: context.ui(10)),
        child: _ChoiceTile(
          label: options[i],
          detail: details?[i],
          selected: selected == options[i],
          onTap: () => onChanged(options[i]),
        ),
      ),
    ),
  );

  Widget _duration(
    BuildContext context,
    double value,
    double max,
    String start,
    String end,
    ValueChanged<double> onChanged,
  ) => Column(
    children: [
      Text(value.toStringAsFixed(1), style: _numberStyle(context, 36)),
      Text('jam', style: _subtitleStyle(context, 13)),
      _CleanSlider(value: value, maximum: max, onChanged: onChanged),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(start, style: _subtitleStyle(context, 12)),
          Text(end, style: _subtitleStyle(context, 12)),
        ],
      ),
      SizedBox(height: context.ui(10)),
      Row(
        children: [
          _SquareButton(
            icon: Icons.remove_rounded,
            onPressed: value <= 0 ? null : () => onChanged(value - .5),
          ),
          SizedBox(width: context.ui(10)),
          Expanded(child: _ValueBox(value: value)),
          SizedBox(width: context.ui(10)),
          _SquareButton(
            icon: Icons.add_rounded,
            onPressed: value >= max ? null : () => onChanged(value + .5),
          ),
        ],
      ),
    ],
  );

  Widget _counter(BuildContext context) => Column(
    children: [
      SizedBox(height: context.ui(12)),
      Text(_coffee.toString(), style: _numberStyle(context, 52)),
      Text('cangkir', style: _subtitleStyle(context, 13)),
      SizedBox(height: context.ui(16)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SquareButton(
            icon: Icons.remove_rounded,
            onPressed: _coffee <= 0 ? null : () => setState(() => _coffee--),
          ),
          _SquareButton(
            icon: Icons.add_rounded,
            onPressed: () => setState(() => _coffee++),
          ),
        ],
      ),
    ],
  );

  Widget _meditationInput(BuildContext context) {
    const values = [0, 5, 10, 15];
    return Column(
      children: [
        Text(_meditation.toString(), style: _numberStyle(context, 46)),
        Text('menit', style: _subtitleStyle(context, 13)),
        SizedBox(height: context.ui(18)),
        Row(
          children: values
              .map(
                (value) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.ui(4)),
                    child: FilledButton(
                      onPressed: () => setState(() => _meditation = value),
                      style: FilledButton.styleFrom(
                        backgroundColor: _meditation == value
                            ? AppColors.primary
                            : AppColors.blob.withValues(alpha: .7),
                        foregroundColor: _meditation == value
                            ? Colors.white
                            : AppColors.primary,
                        minimumSize: Size(0, context.ui(46)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.ui(10)),
                        ),
                      ),
                      child: Text(value.toString()),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: context.ui(16)),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Atau isi durasi sendiri',
            suffixText: 'menit',
          ),
          onChanged: (text) {
            final v = int.tryParse(text);
            if (v != null && v >= 0) setState(() => _meditation = v);
          },
        ),
      ],
    );
  }

  Widget _ratingInput(BuildContext context) => Column(
    children: [
      Text(_rating.round().toString(), style: _numberStyle(context, 46)),
      Text('dari 100', style: _subtitleStyle(context, 13)),
      SizedBox(height: context.ui(18)),
      _CleanSlider(
        value: _rating,
        maximum: 100,
        onChanged: (v) => setState(() => _rating = v),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sangat tidak nyaman', style: _subtitleStyle(context, 10)),
          Text('Sangat nyaman', style: _subtitleStyle(context, 10)),
        ],
      ),
    ],
  );
}

ButtonStyle _backStyle(BuildContext context) => OutlinedButton.styleFrom(
  foregroundColor: AppColors.navy,
  side: const BorderSide(color: AppColors.border),
  minimumSize: Size(0, context.ui(52)),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
  ),
);
ButtonStyle _nextStyle(BuildContext context) => FilledButton.styleFrom(
  backgroundColor: AppColors.primary,
  disabledBackgroundColor: AppColors.primary.withValues(alpha: .35),
  minimumSize: Size(0, context.ui(52)),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
  ),
);
TextStyle _subtitleStyle(BuildContext context, double size) =>
    AppTextStyles.subtitle.copyWith(fontSize: context.ui(size));
TextStyle _numberStyle(BuildContext context, double size) => AppTextStyles.title
    .copyWith(color: AppColors.primary, fontSize: context.ui(size));

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
      activeColor: AppColors.primary,
      inactiveColor: AppColors.blob,
      onChanged: (v) => onChanged((v * 2).round() / 2),
    ),
  );
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => Container(
    height: context.ui(48),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(context.ui(12)),
    ),
    child: RichText(
      text: TextSpan(
        style: _subtitleStyle(
          context,
          14,
        ).copyWith(color: AppColors.navy, fontWeight: FontWeight.w700),
        children: [
          TextSpan(text: value.toStringAsFixed(1)),
          const TextSpan(
            text: ' jam',
            style: TextStyle(
              color: AppColors.body,
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
    color: selected ? AppColors.blob.withValues(alpha: .55) : Colors.white,
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
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.hint,
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
                      color: AppColors.navy,
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
    width: context.ui(48),
    height: context.ui(48),
    child: IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.blob.withValues(alpha: .6),
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.hint,
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
      color: AppColors.blob.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(context.ui(AppSpacing.fieldRadius)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.lightbulb_outline_rounded,
          color: AppColors.primary,
          size: context.ui(22),
        ),
        SizedBox(width: context.ui(10)),
        Expanded(child: Text(text, style: _subtitleStyle(context, 12))),
      ],
    ),
  );
}
