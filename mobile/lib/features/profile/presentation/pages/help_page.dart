import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/profile_subpage_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.onBack});

  final VoidCallback onBack;

  static const _questions = [
    (
      'Bagaimana cara menggunakan AntiBurnout?',
      'Mulai dari Beranda untuk melihat ringkasan kondisi dan motivasi harian. '
          'Gunakan tab Survei untuk mengisi asesmen, Riwayat untuk membuka hasil sebelumnya, '
          'dan Profil untuk mengatur informasi diri.',
    ),
    (
      'Bagaimana cara memulai survei?',
      'Buka tab Survei atau ketuk Mulai Survei di Beranda. Baca pengantar, '
          'lalu pilih jawaban yang paling sesuai dengan kondisimu. '
          'Tinjau kembali jawaban sebelum mengirim. Layanan pengiriman '
          'dan prediksi masih dalam pengembangan.',
    ),
    (
      'Di mana saya bisa melihat hasil sebelumnya?',
      'Buka tab Riwayat, lalu ketuk salah satu asesmen untuk melihat detailnya. '
          'Pencarian dan filter dapat membantu menemukan riwayat. '
          'Data yang ditampilkan saat ini merupakan contoh untuk pratinjau UI.',
    ),
    (
      'Apakah hasil asesmen merupakan diagnosis medis?',
      'Tidak. Hasil asesmen bukan diagnosis medis dan tidak menggantikan '
          'konsultasi dengan tenaga profesional. Gunakan informasi ini '
          'sebagai bahan refleksi untuk lebih mengenali kondisi diri.',
    ),
    (
      'Bagaimana membaca faktor dan ringkasan jawaban?',
      'Faktor dan ringkasan membantu menjelaskan tampilan hasil asesmen. '
          'Pada versi pratinjau ini, isinya adalah data statis. '
          'Ringkasan jawaban tidak menunjukkan besarnya kontribusi model prediksi.',
    ),
    (
      'Bagaimana cara mengubah nama dan foto?',
      'Buka Profil, lalu Edit Profil. Ubah nama atau pilih foto dari galeri, '
          'kemudian ketuk Simpan Perubahan. Perubahan diingat selama sesi '
          'aplikasi dan belum disimpan ke server.',
    ),
    (
      'Bagaimana cara mengubah tema aplikasi?',
      'Buka Profil, lalu Preferensi. Pilih Terang atau Gelap untuk mengubah '
          'tampilan aplikasi, atau Sistem untuk mengikuti tema perangkat. '
          'Pengingat masih berupa pratinjau dan belum mengirim notifikasi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileSubpageScaffold(
      title: 'Bantuan',
      onBack: onBack,
      children: [
        const ProfileInfoCard(
          icon: Icons.help_outline_rounded,
          text:
              'Temukan jawaban tentang penggunaan aplikasi. '
              'Ketuk pertanyaan untuk membaca penjelasannya.',
        ),
        SizedBox(height: context.ui(28)),
        Text(
          'Pertanyaan yang sering diajukan',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(16)),
        for (var index = 0; index < _questions.length; index++) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.of(context).border),
              borderRadius: BorderRadius.circular(context.ui(16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              key: PageStorageKey('faq-$index'),
              maintainState: true,
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: EdgeInsets.symmetric(
                horizontal: context.ui(16),
                vertical: context.ui(6),
              ),
              childrenPadding: EdgeInsets.fromLTRB(
                context.ui(16),
                0,
                context.ui(16),
                context.ui(18),
              ),
              title: Text(
                _questions[index].$1,
                style: AppTextStyles.subtitle(context).copyWith(
                  color: AppColors.of(context).navy,
                  fontWeight: FontWeight.w600,
                  fontSize: context.ui(14),
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _questions[index].$2,
                    style: AppTextStyles.subtitle(context)
                        .copyWith(fontSize: context.ui(13), height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.ui(12)),
        ],
      ],
    );
  }
}
