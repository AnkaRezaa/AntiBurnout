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
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PersonalizationDescription('Ceritakan sedikit tentang dirimu.'),
        PersonalizationDateField(
          label: 'Tanggal Lahir',
          value: data.birthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year, now.month, now.day),
          onChanged: (value) {
            onChanged(
              data.copyWith(birthDate: value, clearBirthDate: value == null),
            );
          },
        ),
        PersonalizationChoices(
          label: 'Jenis kelamin',
          value: data.gender,
          options: const ['Perempuan', 'Laki-laki', 'Lainnya'],
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
