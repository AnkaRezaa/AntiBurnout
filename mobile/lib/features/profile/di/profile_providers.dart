import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/in_memory_profile_repository.dart';
import '../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return InMemoryProfileRepository();
});