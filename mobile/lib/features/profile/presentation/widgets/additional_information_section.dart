import 'package:flutter/material.dart';

import '../../domain/entities/personalization.dart';
import 'personalization_fields.dart';

class AdditionalInformationSection extends StatelessWidget {
  const AdditionalInformationSection({
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
          'Isi jika kamu merasa nyaman.',
        ),
        PersonalizationNumberField(
          label: 'Pendapatan bulanan (IDR)',
          hint: 'Isi jumlah atau biarkan kosong',
          suffix: 'IDR',
          value: data.income,
          onChanged: (value) {
            onChanged(data.copyWith(income: value));
          },
        ),
        PersonalizationChoices(
          label: 'Riwayat kondisi kesehatan mental',
          description:
              'Apakah ada anggota keluarga yang pernah mengalami '
              'gangguan kesehatan mental?',
          value: data.familyMentalHealthHistory,
          options: const [
            'Ya',
            'Tidak',
          ],
          onChanged: (value) {
            onChanged(
              data.copyWith(familyMentalHealthHistory: value),
            );
          },
        ),
        PersonalizationChoices(
          label: 'Dukungan profesional',
          description:
              'Apakah kamu mengikuti terapi atau konseling '
              'untuk kesehatan mental?',
          value: data.professionalSupport,
          options: const [
            'Ya',
            'Tidak',
          ],
          onChanged: (value) {
            onChanged(data.copyWith(professionalSupport: value));
          },
        ),
      ],
    );
  }
}