import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileDetails {
  const ProfileDetails({
    required this.name,
    required this.email,
    this.photoUrl,
    this.photoBytes,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final Uint8List? photoBytes;
}

/// Local presentation state only. It is reset when the signed-in user changes.
class ProfileController extends Notifier<ProfileDetails> {
  @override
  ProfileDetails build() {
    ref.watch(authControllerProvider.select((value) => value.user?.id));
    final user = ref.read(authControllerProvider).user;
    return ProfileDetails(
      name: user?.name.trim().isNotEmpty == true ? user!.name : 'Pengguna',
      email: user?.email ?? '',
      photoUrl: user?.photoUrl,
    );
  }

  bool updateProfile({
    required String name,
    Uint8List? photoBytes,
    bool removePhoto = false,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    state = ProfileDetails(
      name: trimmedName,
      email: state.email,
      photoUrl: removePhoto ? null : state.photoUrl,
      photoBytes: removePhoto ? null : (photoBytes ?? state.photoBytes),
    );
    return true;
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileDetails>(ProfileController.new);

/// Keeping this callback injectable lets the UI be tested without a gallery.
final profileImagePickerProvider = Provider<Future<Uint8List?> Function()>((
  ref,
) {
  return () async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    return image?.readAsBytes();
  };
});
