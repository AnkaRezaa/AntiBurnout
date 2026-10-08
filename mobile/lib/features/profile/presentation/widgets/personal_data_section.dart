import 'package:flutter/material.dart';

import '../../domain/entities/personalization.dart';
import 'personalization_fields.dart';

class PersonalDataSection extends StatelessWidget {
  const PersonalDataSection({
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
        const PersonalizationDescription(
          'Ceritakan sedikit tentang dirimu.',
        ),
        PersonalizationNumberField(
          label: 'Usia',
          hint: 'Masukkan usia',
          suffix: 'tahun',
          value: data.age,
          onChanged: (value) {
            onChanged(data.copyWith(age: value));
          },
          validator: (value) {
            final text = value?.trim() ?? '';

            if (text.isEmpty) return null;

            final age = int.tryParse(text);

            if (age == null || age < 1 || age > 120) {
              return 'Masukkan usia antara 1–120 tahun.';
            }

            return null;
          },
        ),
        PersonalizationChoices(
          label: 'Jenis kelamin',
          value: data.gender,
          options: const [
            'Perempuan',
            'Laki-laki',
            'Lainnya',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(gender: value));
          },
        ),
        PersonalizationDropdown(
          label: 'Negara tempat tinggal',
          hint: 'Pilih negara',
          value: data.country,
          options: const [
            'Indonesia',
            'Malaysia',
            'Singapura',
            'Thailand',
            'Filipina',
            'Vietnam',
            'Lainnya',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(country: value));
          },
        ),
        PersonalizationDropdown(
          label: 'Pendidikan terakhir yang diselesaikan',
          hint: 'Pilih jenjang pendidikan',
          value: data.education,
          options: const [
            'SD / sederajat',
            'SMP / sederajat',
            'SMA / SMK / sederajat',
            'Diploma',
            'D4 / S1',
            'S2',
            'S3',
            'Lainnya',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(education: value));
          },
        ),
      ],
    );
  }
}