import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/assessment_history_item.dart';
import '../controllers/history_controller.dart';
import '../widgets/assessment_history_tile.dart';
import '../widgets/history_empty_view.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_search_field.dart';
import '../controllers/history_state.dart';

class HistoryPage extends ConsumerWidget {
  final VoidCallback? onBack;
  final ValueChanged<AssessmentHistoryItem>? onViewDetail;

  const HistoryPage({super.key, this.onBack, this.onViewDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20),
                   
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 26,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  
                  const SizedBox(width: 4),
                  const Text(
                    'Riwayat Pemeriksaan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              HistorySearchField(onChanged: controller.setQuery),
              const SizedBox(height: 14),

              HistoryFilterBar(
                selected: state.filter,
                onSelected: controller.setFilter,
              ),
              const SizedBox(height: 14),

              const Text(
                'Hasil asesmen burnout sebelumnya.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              Expanded(child: _buildContent(state, controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HistoryState state, HistoryController controller) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return HistoryEmptyView(
        message: state.errorMessage!,
        onRetry: controller.load,
      );
    }

    final visible = state.visibleItems;
    if (visible.isEmpty) {
      return HistoryEmptyView(
        message: state.items.isEmpty
            ? 'Belum ada riwayat pemeriksaan.'
            : 'Riwayat tidak ditemukan.',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = visible[index];
          return AssessmentHistoryTile(
            item: item,
            isLatest: item.id == state.latestId,
            onDetailTap: () => onViewDetail?.call(item),
          );
        },
      ),
    );
  }
}