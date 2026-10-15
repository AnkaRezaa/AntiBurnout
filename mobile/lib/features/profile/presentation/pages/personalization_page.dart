import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../controllers/personalization_controller.dart';
import '../widgets/activity_section.dart';
import '../widgets/additional_information_section.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/personalization_fields.dart';

class PersonalizationPage extends ConsumerStatefulWidget {
  const PersonalizationPage({
    super.key,
    required this.onBack,
    this.backTooltip = 'Kembali ke profil',
  });

  final VoidCallback onBack;
  final String backTooltip;

  @override
  ConsumerState<PersonalizationPage> createState() =>
      _PersonalizationPageState();
}

class _PersonalizationPageState extends ConsumerState<PersonalizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  int _step = 0;

  static const _tabs = ['Data Diri', 'Aktivitas', 'Tambahan'];

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
        color: PersonalizationFieldStyle.softColor(context),
        borderRadius: BorderRadius.circular(context.ui(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kenali dirimu lebih dekat',
            style: TextStyle(
              color: AppColors.of(context).navy,
              fontSize: context.ui(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.ui(6)),
          Text(
            'Isi sekali untuk melengkapi surveimu.\n'
            'Perbarui kapan pun kondisimu berubah.',
            style: TextStyle(
              color: AppColors.of(context).hint,
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
                      ? AppColors.of(context).onPrimary
                      : AppColors.of(context).hint,
                  backgroundColor: index == _step
                      ? AppColors.of(context).primary
                      : PersonalizationFieldStyle.softColor(context),
                  minimumSize: const Size(0, 48),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(4),
                    vertical: context.ui(10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.ui(12)),
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
    final controller = ref.read(personalizationControllerProvider.notifier);

    Widget body;

    if (state.isLoading) {
      body = Center(
        child: CircularProgressIndicator(color: AppColors.of(context).primary),
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
                  color: AppColors.of(context).hint,
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
                      color: AppColors.of(context).navy,
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
                  color: AppColors.of(context).error,
                  fontSize: context.ui(13),
                ),
              ),
            ],
            SizedBox(height: context.ui(12)),
            AppButton(
              label: _step == 2 ? 'Simpan Personalisasi' : 'Selanjutnya',
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
            Wrap(
              alignment: _step > 0
                  ? WrapAlignment.spaceBetween
                  : WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.ui(16),
              runSpacing: context.ui(8),
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: state.isSaving
                        ? null
                        : () => _changeStep(_step - 1),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.ui(16),
                        vertical: context.ui(10),
                      ),
                    ),
                    child: Text(
                      'Sebelumnya',
                      style: TextStyle(
                        color: AppColors.of(context).primary,
                        fontSize: context.ui(14),
                      ),
                    ),
                  ),
                Text(
                  'Langkah ${_step + 1} dari 3',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.of(context).hint,
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
        backgroundColor: AppColors.of(context).background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Personalisasi Profil',
                onBack: state.isSaving ? null : widget.onBack,
                tooltip: widget.backTooltip,
              ),
              SizedBox(height: context.ui(16)),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
