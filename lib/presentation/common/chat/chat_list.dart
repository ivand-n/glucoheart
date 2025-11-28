import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/discussion_message.dart';
import 'message_bubble.dart';

class ChatList extends ConsumerWidget {
  final List<DiscussionMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final ScrollController? scrollController;
  final Function()? onRefresh;

  const ChatList({
    super.key,
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
    this.scrollController,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              if (onRefresh != null)
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Coba Lagi'),
                ),
            ],
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Belum ada pesan. Mulai diskusi sekarang!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Penting: Kita TIDAK pakai reverse lagi, urutan kronologis dari awal -> akhir.
    // Separator tanggal dibuat inline (bukan sticky), jadi tidak "nempel" saat scroll.
    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          final m = messages[i];
          final bool showDateHeader = i == 0 ||
              !_isSameDay(messages[i - 1].createdAt, m.createdAt);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDateHeader) _DateSeparator(date: m.createdAt),
                MessageBubble(
                  message: m,
                  showAvatar: true,
                  showTime: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final label = _label(date);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _label(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dd = DateTime(d.year, d.month, d.day);

    if (dd == today) return 'Hari ini';
    if (dd == yesterday) return 'Kemarin';
    return DateFormat('dd MMMM yyyy', 'id').format(d);
  }
}
