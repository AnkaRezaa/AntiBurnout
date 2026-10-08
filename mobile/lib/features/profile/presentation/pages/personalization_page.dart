import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/personalization_controller.dart';
import '../widgets/activity_section.dart';
import '../widgets/additional_information_section.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/personalization_fields.dart';
import '../../../../core/theme/app_text_styles.dart';

class PersonalizationPage extends ConsumerStatefulWidget {
  const PersonalizationPage({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  ConsumerState<PersonalizationPage> createState() =>
      _PersonalizationPageState();
}

class _PersonalizationPageState
    extends ConsumerState<PersonalizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  int _step = 0;

  static const _tabs = [
    'Data Diri',
    'Aktivitas',
    'Tambahan',
  ];

  static const _titles = [
    'Informasi dasar',
    'Aktivitas & kebiasaan',
    'Informasi tambahan',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeStep(int next) {
    if (next == _step || next < 0 || next >= _tabs.length) {
      return;
    }

    final state = ref.read(personalizationControllerProvider);

    if (state.isSaving || state.isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _step = next;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(personalizationControllerProvider.notifier)
        .save();

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Personalisasi tersimpan untuk sesi ini.'),
        ),
      );

    widget.onBack();
  }

  Widget _buildIntroduction() {
    return Container(
      padding: EdgeInsets.all(context.ui(14)),
      decoration: BoxDecoration(
        color: PersonalizationFieldStyle.softColor,
        borderRadius: BorderRadius.circular(context.ui(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kenali dirimu lebih dekat',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: context.ui(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.ui(6)),
          Text(
            'Isi sekali untuk melengkapi surveimu.\n'
            'Perbarui kapan pun kondisimu berubah.',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: context.ui(12),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        for (var index = 0; index < _tabs.length; index++) ...[
          if (index > 0) SizedBox(width: context.ui(8)),
          Expanded(
            child: Semantics(
              selected: index == _step,
              child: TextButton(
                onPressed: () => _changeStep(index),
                style: TextButton.styleFrom(
                  foregroundColor: index == _step
                      ? Colors.white
                      : AppColors.hint,
                  backgroundColor: index == _step
                      ? AppColors.primary
                      : PersonalizationFieldStyle.softColor,
                  minimumSize: const Size(0, 48),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(4),
                    vertical: context.ui(10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.ui(12),
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.ui(12),
                    fontWeight: index == _step
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalizationControllerProvider);
    final controller = ref.read(
      personalizationControllerProvider.notifier,
    );

    Widget body;

    if (state.isLoading) {
      body = const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    } else if (!state.isLoaded) {
      body = Center(
        child: Padding(
          padding: EdgeInsets.all(context.ui(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Personalisasi belum tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.hint,
                  fontSize: context.ui(14),
                ),
              ),
              if (state.userId != null) ...[
                SizedBox(height: context.ui(16)),
                AppButton(
                  label: 'Coba Lagi',
                  onPressed: () {
                    controller.reload();
                  },
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      body = SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          context.ui(24),
          0,
          context.ui(24),
          context.ui(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIntroduction(),
            SizedBox(height: context.ui(18)),
            AbsorbPointer(
              absorbing: state.isSaving,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTabs(),
                  SizedBox(height: context.ui(20)),
                  Text(
                    _titles[_step],
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: context.ui(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.ui(8)),
                  Form(
                    key: _formKey,
                    child: KeyedSubtree(
                      key: ValueKey('${state.userId}-$_step'),
                      child: switch (_step) {
                        0 => PersonalDataSection(
                            data: state.data,
                            onChanged: controller.update,
                          ),
                        1 => ActivitySection(
                            data: state.data,
                            onChanged: controller.update,
                          ),
                        _ => AdditionalInformationSection(
                            data: state.data,
                            onChanged: controller.update,
                          ),
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null) ...[
              SizedBox(height: context.ui(8)),
              Text(
                state.errorMessage!,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: context.ui(13),
                ),
              ),
            ],
            SizedBox(height: context.ui(12)),
            AppButton(
              label: _step == 2
                  ? 'Simpan Personalisasi'
                  : 'Selanjutnya',
              isLoading: state.isSaving,
              onPressed: state.isSaving
                  ? null
                  : () {
                      if (_step == 2) {
                        _save();
                      } else {
                        _changeStep(_step + 1);
                      }
                    },
            ),
            SizedBox(height: context.ui(8)),
            Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: state.isSaving
                        ? null
                        : () => _changeStep(_step - 1),
                    child: Text(
                      'Sebelumnya',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: context.ui(14),
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'Langkah ${_step + 1} dari 3',
                  style: TextStyle(
                    color: AppColors.hint,
                    fontSize: context.ui(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !state.isSaving) {
          widget.onBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.ui(24),
                  context.ui(28),
                  context.ui(24),
                  0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: context.ui(30)),
                      child: Text(
                        'Personalisasi Profil',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.navy,
                          fontSize: context.ui(24),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: -context.ui(12),
                      width: context.ui(40),
                      child: IconButton(
                        onPressed: state.isSaving ? null : widget.onBack,
                        tooltip: 'Kembali ke profil',
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.navy,
                          size: context.ui(28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.ui(26)),
              Expanded(
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}