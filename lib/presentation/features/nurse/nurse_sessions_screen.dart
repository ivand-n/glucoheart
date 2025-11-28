import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/themes/app_theme.dart';
import '../../providers/nurse_sessions_provider.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/chat_message.dart';
import '../chat/chat_screen.dart';

class NurseSessionsScreen extends ConsumerStatefulWidget {
  const NurseSessionsScreen({super.key});

  @override
  ConsumerState<NurseSessionsScreen> createState() => _NurseSessionsScreenState();
}

class _NurseSessionsScreenState extends ConsumerState<NurseSessionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await ref.read(nurseSessionsProvider.notifier).loadAssignedSessions();
    if (mounted) setState(() => _initialLoaded = true);
  }

  // ---- Helpers ----
  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    return timeago.format(dt, locale: 'id');
  }

  String _preview(ChatMessage? m) {
    if (m == null) return 'Belum ada percakapan';
    final who = (m.senderName ?? '').trim();
    final text = m.content.trim().isEmpty ? '(pesan kosong)' : m.content.trim();
    return who.isEmpty ? text : '$who: $text';
  }

  List<ChatSession> _applyFilter(List<ChatSession> list) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((s) {
      final title = 'Session #${s.id}'.toLowerCase();
      final content = (s.lastMessage?.content ?? '').toLowerCase();
      return title.contains(q) || content.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nurseSessionsProvider);

    // Realtime listener: ketika state.sessions berubah (mis. ada message.new),
    // kita re-render (Consumer sudah melakukan), dan OPTIONAL bisa kasih feedback kecil.
    ref.listen<NurseSessionsState>(nurseSessionsProvider, (prev, next) {
      if (prev == null) return;
      if (prev.sessions.isNotEmpty && next.sessions.isNotEmpty) {
        // contoh: kalau id teratas berubah, artinya ada bump oleh pesan baru
        if (prev.sessions.first.id != next.sessions.first.id ||
            prev.sessions.first.lastMessage?.id != next.sessions.first.lastMessage?.id) {
          // Bisa getar ringan / snackbar, tapi tidak wajib
          // HapticFeedback.selectionClick();
        }
      }
    });


    // Lazy-load sekali (mirip pattern di DiscussionListScreen)
    if (!_initialLoaded) {
      // Jangan blocking build pertama, pakai microtask
      Future.microtask(_load);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0.5,
        titleSpacing: 16,
        title: const Text('Assigned Chats'),
        actions: [
          IconButton(
            onPressed: () => ref.read(nurseSessionsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR — sama gaya dengan DiscussionListScreen
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.12)),
              ),
            ),
            child: _SearchField(controller: _searchCtrl),
          ),

          // BODY
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: state.isLoading && !_initialLoaded
                  ? const _LoadingState()
                  : (state.error != null && state.sessions.isEmpty
                  ? _ErrorState(
                message: state.error!,
                onRetry: () => ref.read(nurseSessionsProvider.notifier).refresh(),
              )
                  : _ListView(
                sessions: _applyFilter(state.sessions),
                onRefresh: () => ref.read(nurseSessionsProvider.notifier).refresh(),
                itemBuilder: (s) => _SessionCard(
                  title: 'Session #${s.id}',
                  subtitle: _preview(s.lastMessage),
                  timeLabel: _relativeTime(
                    s.lastMessage?.createdAt ?? s.lastMessageAt ?? s.updatedAt,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id)),
                    );
                  },
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Widgets (UI seragam dengan DiscussionListScreen) ----------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final showClear = controller.text.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Cari session atau pesan…',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (showClear)
            IconButton(
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
              tooltip: 'Bersihkan',
              splashRadius: 18,
            ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<ChatSession> sessions;
  final Future<void> Function() onRefresh;
  final Widget Function(ChatSession) itemBuilder;

  const _ListView({
    required this.sessions,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => itemBuilder(sessions[i]),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeLabel;
  final VoidCallback onTap;

  const _SessionCard({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (title.isNotEmpty ? title.trim()[0] : '?').toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              // Avatar inisial
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Preview pesan
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Waktu + titik status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    Widget skeleton() => Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.10)),
      ),
    );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemBuilder: (_, __) => skeleton(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: 6,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.primaryColor),
            const SizedBox(height: 10),
            Text(
              'Belum ada chat yang di-assign',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tunggu admin meng-assign pasien, atau tarik untuk menyegarkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
