import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/features/assessment/di/assessment_providers.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/dashboard/presentation/widgets/latest_assessment_card.dart';
import 'package:mobile/features/history/presentation/controllers/history_repository.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_tile.dart';
import 'package:mobile/features/profile/di/profile_providers.dart';
import 'package:mobile/features/profile/domain/entities/personalization.dart';
import 'package:mobile/features/profile/presentation/controllers/personalization_controller.dart';
import 'package:mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:mobile/features/profile/presentation/controllers/preferences_controller.dart';
import 'package:mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/preferences_page.dart';
import 'package:mobile/features/profile/presentation/pages/help_page.dart';
import 'package:mobile/features/profile/presentation/pages/about_page.dart';
import 'package:mobile/features/results/presentation/pages/result_page.dart';
import 'package:mobile/shared/widgets/app_back_button.dart';
import 'package:mobile/shared/widgets/user_avatar.dart';

class _Session extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(
      id: 'preview-user',
      email: 'preview@example.com',
      name: 'Nama Awal',
    ),
  );

  void switchUser() => state = const AuthState.authenticated(
    AuthUser(
      id: 'other-user',
      email: 'other@example.com',
      name: 'Pengguna Lain',
    ),
  );
}

Future<ProviderContainer> _start(
  WidgetTester tester, {
  Future<Uint8List?> Function()? pickPhoto,
}) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_Session.new),
      if (pickPhoto != null)
        profileImagePickerProvider.overrideWithValue(pickPhoto),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AntiBurnoutApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(label),
        )
        .last,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.pump();
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _choosePhoto(WidgetTester tester) async {
  final target = find.text('Ubah Foto');
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump();
  // Image decoding uses the real engine event loop.
  await tester.runAsync(() async {
    for (var attempt = 0; attempt < 100; attempt++) {
      if (find.text('Membuka galeri...').evaluate().isEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();
    }
  });
  await tester.pumpAndSettle();
}

void _smallTextViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.8;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets(
    'all demo history results have static factors and answer summaries',
    (tester) async {
      final container = await _start(tester);
      for (final item in container.read(assessmentFixtureProvider)) {
        final result = await container.read(
          assessmentByIdProvider(item.id).future,
        );
        expect(result!.id, item.id);
        expect(result.riskLevel, item.riskLevel);
        expect(result.takenAt, item.takenAt);
        expect(result.isExample, isTrue);
        expect(result.modelFactors, hasLength(3));
        expect(result.answerSummary, hasLength(7));
        container.read(appRouterProvider).go(RoutePaths.resultFor(item.id));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Data contoh'), findsOneWidget);
        expect(find.text('Durasi tidur kurang stabil'), findsOneWidget);
        expect(
          find.textContaining('Ringkasan jawaban belum tersedia'),
          findsNothing,
        );
        expect(
          find.textContaining('Faktor dari model belum tersedia'),
          findsNothing,
        );
        expect(find.textContaining('bukan diagnosis medis'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'survey introduction and history list use navbar without a back button',
    (tester) async {
      await _start(tester);
      await _tab(tester, 'Survei');
      expect(find.byType(AppBackButton), findsNothing);
      await _tab(tester, 'Riwayat');
      expect(find.byType(AppBackButton), findsNothing);
      await tester.tap(find.byType(AssessmentHistoryTile).first);
      await tester.pumpAndSettle();
      expect(find.byType(ResultPage), findsOneWidget);
      expect(find.byType(AppBackButton), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ResultPage), findsNothing);
      expect(find.byType(AssessmentHistoryTile), findsWidgets);
    },
  );

  testWidgets('risk badge is aligned with right edge of card content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _start(tester);
    final card = tester.getRect(find.byType(LatestAssessmentCard));
    final badgeText = tester.getRect(find.text('SEDANG'));
    // At the design size: card padding 22 + badge's right inset 12.
    expect(badgeText.right, closeTo(card.right - 34, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'name and selected photo update profile and dashboard for the session',
    (tester) async {
      final bytes = (await rootBundle.load('assets/images/profile-male.png'))
          .buffer
          .asUint8List();
      final container = await _start(tester, pickPhoto: () async => bytes);
      await _tab(tester, 'Profil');
      await _tap(tester, 'Edit Profil');
      await tester.enterText(
        find.byKey(const Key('edit-profile-name')),
        'Nama Baru',
      );
      await _choosePhoto(tester);
      expect(
        tester.widget<UserAvatar>(find.byType(UserAvatar)).photoBytes,
        bytes,
      );
      await _tab(tester, 'Beranda');
      expect(find.text('Nama Awal!'), findsOneWidget);
      await _tab(tester, 'Profil');
      expect(find.byType(EditProfilePage), findsOneWidget);
      expect(find.text('Nama Baru'), findsOneWidget);
      await _tap(tester, 'Simpan Perubahan');
      expect(container.read(profileControllerProvider).name, 'Nama Baru');
      expect(container.read(profileControllerProvider).photoBytes, bytes);
      await _tab(tester, 'Beranda');
      expect(find.text('Nama Baru!'), findsOneWidget);
      expect(
        tester.widget<UserAvatar>(find.byType(UserAvatar)).photoBytes,
        bytes,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty names are rejected and cancel leaves session profile untouched',
    (tester) async {
      final container = await _start(tester, pickPhoto: () async => null);
      await _tab(tester, 'Profil');
      await _tap(tester, 'Edit Profil');
      await tester.enterText(find.byKey(const Key('edit-profile-name')), '   ');
      await _tap(tester, 'Simpan Perubahan');
      expect(find.text('Nama tidak boleh kosong.'), findsOneWidget);
      expect(container.read(profileControllerProvider).name, 'Nama Awal');
      await tester.enterText(
        find.byKey(const Key('edit-profile-name')),
        'Batal Disimpan',
      );
      await _tap(tester, 'Ubah Foto');
      await _tap(tester, 'Batal');
      expect(find.byType(EditProfilePage), findsNothing);
      expect(container.read(profileControllerProvider).name, 'Nama Awal');
      expect(container.read(profileControllerProvider).photoBytes, isNull);
    },
  );

  testWidgets('profile edits reset on account change', (tester) async {
    final container = await _start(tester);
    container
        .read(profileControllerProvider.notifier)
        .updateProfile(name: 'Nama Lokal');
    await tester.pumpAndSettle();
    (container.read(authControllerProvider.notifier) as _Session).switchUser();
    await tester.pumpAndSettle();
    expect(container.read(profileControllerProvider).name, 'Pengguna Lain');
    expect(
      container.read(profileControllerProvider).email,
      'other@example.com',
    );
    expect(container.read(profileControllerProvider).photoBytes, isNull);
  });

  testWidgets('an open edit draft is reset when the account changes', (
    tester,
  ) async {
    final container = await _start(tester);
    await _tab(tester, 'Profil');
    await _tap(tester, 'Edit Profil');
    await tester.enterText(
      find.byKey(const Key('edit-profile-name')),
      'Draft Akun Lama',
    );
    (container.read(authControllerProvider.notifier) as _Session).switchUser();
    await tester.pumpAndSettle();
    expect(find.text('Draft Akun Lama'), findsNothing);
    expect(find.text('Pengguna Lain'), findsOneWidget);
    await _tap(tester, 'Simpan Perubahan');
    expect(container.read(profileControllerProvider).name, 'Pengguna Lain');
    expect(container.read(profileControllerProvider).photoBytes, isNull);
  });

  testWidgets(
    'profile subpages keep the profile navbar branch and return with Android back',
    (tester) async {
      final container = await _start(tester);
      await _tab(tester, 'Profil');
      for (final entry in [
        ('Preferensi', PreferencesPage),
        ('Bantuan', HelpPage),
        ('Tentang Aplikasi', AboutPage),
      ]) {
        await _tap(tester, entry.$1);
        expect(find.byType(entry.$2), findsOneWidget);
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          3,
        );
        await _tab(tester, 'Beranda');
        await _tab(tester, 'Profil');
        expect(find.byType(entry.$2), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          container
              .read(appRouterProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          RoutePaths.profile,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'profile content and demo results stay scrollable with enlarged text',
    (tester) async {
      _smallTextViewport(tester);
      final container = await _start(tester);
      for (final location in [
        RoutePaths.editProfile,
        RoutePaths.preferences,
        RoutePaths.help,
        RoutePaths.about,
        RoutePaths.personalization,
        RoutePaths.resultFor('4'),
      ]) {
        container.read(appRouterProvider).go(location);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: location);
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: location);
      }
    },
  );

  testWidgets(
    'preferences apply and retain theme while reminder choices stay available',
    (tester) async {
      final container = await _start(tester);
      await _tab(tester, 'Profil');
      await _tap(tester, 'Preferensi');
      await _tap(tester, 'Gelap');
      await _tap(tester, 'Pengingat harian');
      expect(
        container.read(preferencesControllerProvider).themeMode,
        ThemeMode.dark,
      );
      expect(
        container.read(preferencesControllerProvider).dailyReminder,
        isTrue,
      );
      final darkOption = find.byKey(const ValueKey('theme-option-dark'));
      expect(Theme.of(tester.element(darkOption)).brightness, Brightness.dark);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await _tap(tester, 'Preferensi');
      expect(Theme.of(tester.element(darkOption)).brightness, Brightness.dark);
      expect(
        container.read(preferencesControllerProvider).dailyReminder,
        isTrue,
      );
    },
  );

  testWidgets('birth date can be selected, saved, reopened and cleared', (
    tester,
  ) async {
    final container = await _start(tester);
    final repository = container.read(profileRepositoryProvider);
    await repository.savePersonalization(
      userId: 'preview-user',
      personalization: Personalization(birthDate: DateTime(2000, 1, 15)),
    );
    await _tab(tester, 'Profil');
    await _tap(tester, 'Personalisasi Profil');
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('15/01/2000'), findsOneWidget);
    expect(find.text('Umur'), findsNothing);
    await _tap(tester, '15/01/2000');
    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
    await _tap(tester, 'Batal');
    expect(find.text('15/01/2000'), findsOneWidget);
    await _tap(tester, '15/01/2000');
    await _tap(tester, '16');
    await _tap(tester, 'Pilih');
    expect(find.text('16/01/2000'), findsOneWidget);
    await _tap(tester, 'Aktivitas');
    await _tap(tester, 'Data Diri');
    expect(find.text('16/01/2000'), findsOneWidget);
    await _tab(tester, 'Beranda');
    await _tab(tester, 'Profil');
    expect(find.text('16/01/2000'), findsOneWidget);
    await _tap(tester, 'Tambahan');
    await _tap(tester, 'Simpan Personalisasi');
    expect(
      (await repository.getPersonalization('preview-user'))?.birthDate,
      DateTime(2000, 1, 16),
    );
    await _tap(tester, 'Personalisasi Profil');
    expect(find.text('16/01/2000'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus tanggal lahir'));
    await tester.pumpAndSettle();
    expect(find.text('16/01/2000'), findsNothing);
    await _tap(tester, 'Tambahan');
    await _tap(tester, 'Simpan Personalisasi');
    expect(
      (await repository.getPersonalization('preview-user'))?.birthDate,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('future birth dates cannot be saved', (tester) async {
    final container = await _start(tester);
    await _tab(tester, 'Profil');
    await _tap(tester, 'Personalisasi Profil');
    final controller = container.read(
      personalizationControllerProvider.notifier,
    );
    controller.update(
      Personalization(birthDate: DateTime.now().add(const Duration(days: 1))),
    );
    expect(await controller.save(), isFalse);
    expect(
      container.read(personalizationControllerProvider).errorMessage,
      contains('hari ini'),
    );
    expect(
      await container
          .read(profileRepositoryProvider)
          .getPersonalization('preview-user'),
      isNull,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FAQ expands and remains expanded after a tab switch', (
    tester,
  ) async {
    await _start(tester);
    await _tab(tester, 'Profil');
    await _tap(tester, 'Bantuan');
    await _tap(tester, 'Bagaimana cara menggunakan AntiBurnout?');
    final answer = find.textContaining(
      'Mulai dari Beranda untuk melihat ringkasan',
    );
    expect(answer.hitTestable(), findsOneWidget);
    await _tab(tester, 'Beranda');
    await _tab(tester, 'Profil');
    expect(answer.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
