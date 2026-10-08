import '../entities/personalization.dart';

abstract class ProfileRepository {
  Future<Personalization?> getPersonalization(String userId);

  Future<void> savePersonalization({
    required String userId,
    required Personalization personalization,
  });
}