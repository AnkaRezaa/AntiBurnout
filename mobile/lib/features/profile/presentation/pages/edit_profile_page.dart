import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_subpage_scaffold.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final String _email;
  String? _photoUrl;
  Uint8List? _photoBytes;
  bool _removePhoto = false;
  bool _isPickingPhoto = false;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _nameController = TextEditingController(text: profile.name);
    _email = profile.email;
    _photoUrl = profile.photoUrl;
    _photoBytes = profile.photoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    setState(() {
      _isPickingPhoto = true;
      _photoError = null;
    });
    try {
      final bytes = await ref.read(profileImagePickerProvider)();
      if (!mounted || bytes == null) return;
      if (bytes.isEmpty) throw const FormatException('Empty image');
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _removePhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _photoError = 'Foto belum dapat dibuka. Izinkan akses galeri atau coba foto lain.';
      });
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _save() {
    if (_isPickingPhoto || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    final saved = ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          photoBytes: _photoBytes,
          removePhoto: _removePhoto,
        );
    if (!saved) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Profil diperbarui untuk sesi ini.')),
      );
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSubpageScaffold(
      title: 'Edit Profil',
      onBack: widget.onBack,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: UserAvatar(
                  size: 108,
                  photoUrl: _photoUrl,
                  photoBytes: _photoBytes,
                ),
              ),
              SizedBox(height: context.ui(12)),
              Center(
                child: TextButton.icon(
                  onPressed: _isPickingPhoto ? null : _pickPhoto,
                  icon: _isPickingPhoto
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _isPickingPhoto ? 'Membuka galeri...' : 'Ubah Foto',
                  ),
                ),
              ),
              if (_photoBytes != null || _photoUrl?.isNotEmpty == true)
                Center(
                  child: TextButton(
                    onPressed: _isPickingPhoto
                        ? null
                        : () => setState(() {
                            _photoBytes = null;
                            _photoUrl = null;
                            _removePhoto = true;
                            _photoError = null;
                          }),
                    child: const Text('Gunakan avatar bawaan'),
                  ),
                ),
              if (_photoError != null)
                Padding(
                  padding: EdgeInsets.only(top: context.ui(8)),
                  child: Text(
                    _photoError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle(context)
                        .copyWith(color: AppColors.of(context).error),
                  ),
                ),
              SizedBox(height: context.ui(28)),
              TextFormField(
                key: const Key('edit-profile-name'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama kamu',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama tidak boleh kosong.'
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              SizedBox(height: context.ui(18)),
              TextFormField(
                initialValue: _email,
                enabled: false,
                readOnly: true,
                style: TextStyle(color: AppColors.of(context).hint),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppColors.of(context).hint),
                  helperText: 'Email tidak dapat diubah.',
                  filled: true,
                  fillColor: AppColors.of(context).disabledSurface,
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.of(context).hint,
                  ),
                ),
              ),
              SizedBox(height: context.ui(26)),
              const ProfileInfoCard(
                text:
                    'Nama dan foto tersimpan selama sesi aplikasi ini. '
                    'Perubahan belum disinkronkan ke akun.',
              ),
              SizedBox(height: context.ui(28)),
              AppButton(
                label: 'Simpan Perubahan',
                onPressed: _isPickingPhoto ? null : _save,
              ),
              SizedBox(height: context.ui(8)),
              TextButton(onPressed: widget.onBack, child: const Text('Batal')),
            ],
          ),
        ),
      ],
    );
  }
}
