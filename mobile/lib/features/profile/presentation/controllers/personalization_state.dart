import '../../domain/entities/personalization.dart';

class PersonalizationState {
  const PersonalizationState({
    this.userId,
    this.data = const Personalization(),
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.errorMessage,
  });

  final String? userId;
  final Personalization data;
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? errorMessage;

  PersonalizationState copyWith({
    Personalization? data,
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalizationState(
      userId: userId,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}