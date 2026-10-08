import '../../domain/entities/personalization.dart';
import '../../domain/repositories/profile_repository.dart';

class InMemoryProfileRepository implements ProfileRepository {
  final Map<String, Personalization> _personalizations = {};

  @override
  Future<Personalization?> getPersonalization(String userId) async {
    return _personalizations[userId];
  }

  @override
  Future<void> savePersonalization({
    required String userId,
    required Personalization personalization,
  }) async {
    _personalizations[userId] = personalization;
  }
}