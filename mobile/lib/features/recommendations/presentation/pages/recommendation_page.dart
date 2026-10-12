import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      _RecommendationItem(
        icon: Icons.bedtime_rounded,
        iconBg: const Color(0xFFE0F2FE),
        title: 'Perbaiki Pola Tidur',
        body:
            'Usahakan tidur 7-8 jam per hari dengan jadwal yang konsisten.',
      ),
      _RecommendationItem(
        icon: Icons.self_improvement_rounded,
        iconBg: const Color(0xFFE0E7FF),
        title: 'Kelola Aktivitas',
        body:
            'Coba prioritaskan tugas penting dan sisihkan waktu istirahat secara teratur.',
      ),
      _RecommendationItem(
        icon: Icons.groups_rounded,
        iconBg: const Color(0xFFFCE7F3),
        title: 'Cari Dukungan Sosial',
        body:
            'Jangan ragu untuk berdiskusi dengan teman, keluarga, atau profesional jika merasa terbebani.',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Rekomendasi untuk Kamu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Berikut beberapa langkah yang bisa kamu lakukan untuk membantu menjaga risiko burnout.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: recommendations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = recommendations[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              size: 22,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF475569),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String body;

  const _RecommendationItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
  });
}
