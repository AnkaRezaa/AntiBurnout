import 'package:flutter/material.dart';

import '../../domain/entities/personalization.dart';
import 'personalization_fields.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final Personalization data;
  final ValueChanged<Personalization> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PersonalizationDropdown(
          label: 'Pekerjaan / aktivitas utama',
          hint: 'Pilih aktivitas utama',
          value: data.occupation,
          options: const [
            'Pelajar / Mahasiswa',
            'Karyawan',
            'Wirausaha',
            'Freelancer',
            'Mengurus rumah tangga',
            'Belum bekerja',
            'Lainnya',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(occupation: value));
          },
        ),
        PersonalizationDropdown(
          label: 'Status pekerjaan',
          hint: 'Pilih status pekerjaan',
          value: data.employmentStatus,
          options: const [
            'Penuh waktu',
            'Paruh waktu',
            'Kontrak',
            'Magang',
            'Bekerja mandiri',
            'Tidak bekerja',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(employmentStatus: value));
          },
        ),
        PersonalizationChoices(
          label: 'Lokasi kerja',
          value: data.workLocation,
          options: const [
            'Rumah',
            'Kantor',
            'Hybrid',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(workLocation: value));
          },
        ),
        PersonalizationChoices(
          label: 'Apakah kamu merokok?',
          value: data.smoking,
          options: const [
            'Ya',
            'Tidak',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(smoking: value));
          },
        ),
        PersonalizationChoices(
          label: 'Apakah kamu mengonsumsi alkohol?',
          value: data.alcohol,
          options: const [
            'Ya',
            'Tidak',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(alcohol: value));
          },
        ),
      ],
    );
  }
}