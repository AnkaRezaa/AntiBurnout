import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/personalization.dart';
import '../../domain/repositories/profile_repository.dart';
import 'personalization_state.dart';

class PersonalizationController extends Notifier<PersonalizationState> {
  int _generation = 0;

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  PersonalizationState build() {
    final userId = ref.watch(
      authControllerProvider.select((value) => value.user?.id),
    );

    final generation = ++_generation;

    ref.onDispose(() {
      _generation++;
    });

    if (userId == null) {
      return const PersonalizationState(
        errorMessage: 'Silakan masuk terlebih dahulu.',
      );
    }

    final repository = _repository;

    Future<void>.microtask(() async {
      if (generation != _generation) return;
      await _load(repository, userId, generation);
    });

    return PersonalizationState(
      userId: userId,
      isLoading: true,
    );
  }

  Future<void> _load(
    ProfileRepository repository,
    String userId,
    int generation,
  ) async {
    try {
      final data = await repository.getPersonalization(userId);

      if (generation != _generation) return;

      state = PersonalizationState(
        userId: userId,
        data: data ?? const Personalization(),
        isLoaded: true,
      );
    } catch (_) {
      if (generation != _generation) return;

      state = PersonalizationState(
        userId: userId,
        errorMessage: 'Personalisasi gagal dimuat. Silakan coba lagi.',
      );
    }
  }

  Future<void> reload() async {
    final userId = state.userId;

    if (userId == null || state.isLoading || state.isSaving) return;

    final generation = ++_generation;
    final repository = _repository;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    await _load(repository, userId, generation);
  }

  void update(Personalization data) {
    if (!state.isLoaded || state.isSaving) return;

    state = state.copyWith(
      data: data,
      clearError: true,
    );
  }

  Future<bool> save() async {
    final userId = state.userId;

    if (userId == null ||
        !state.isLoaded ||
        state.isLoading ||
        state.isSaving) {
      return false;
    }

    final ageText = state.data.age.trim();

    if (ageText.isNotEmpty) {
      final age = int.tryParse(ageText);

      if (age == null || age < 1 || age > 120) {
        state = state.copyWith(
          errorMessage: 'Masukkan usia antara 1–120 tahun.',
        );

        return false;
      }
    }

    final generation = _generation;
    final repository = _repository;
    final data = state.data.copyWith(
      age: ageText,
      income: state.data.income.trim(),
    );

    state = state.copyWith(
      isSaving: true,
      clearError: true,
    );

    try {
      await repository.savePersonalization(
        userId: userId,
        personalization: data,
      );

      if (generation != _generation) return false;

      state = state.copyWith(
        data: data,
        isSaving: false,
        clearError: true,
      );

      return true;
    } catch (_) {
      if (generation != _generation) return false;

      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Personalisasi gagal disimpan. Silakan coba lagi.',
      );

      return false;
    }
  }
}

final personalizationControllerProvider =
    NotifierProvider<PersonalizationController, PersonalizationState>(
  PersonalizationController.new,
);