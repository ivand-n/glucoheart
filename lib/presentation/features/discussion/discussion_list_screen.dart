import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/data/repositories/discussion_repository_impl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/discussion_room.dart';
import '../../../domain/entities/discussion_message.dart';
import '../../providers/discussion_provider.dart';
import 'discussion_room_screen.dart';

class DiscussionListScreen extends ConsumerStatefulWidget {
  const DiscussionListScreen({super.key});

  @override
  ConsumerState<DiscussionListScreen> createState() => _DiscussionListScreenState();
}

class _DiscussionListScreenState extends ConsumerState<DiscussionListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<DiscussionRoom> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(discussionRepositoryProvider);
      final rooms = await repo.listRooms();
      setState(() {
        _rooms = _sortRooms(rooms);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<DiscussionRoom> _sortRooms(List<DiscussionRoom> list) {
    final copy = [...list];
    copy.sort((a, b) {
      final ta = a.lastMessage?.createdAt ?? a.lastMessageAt ?? a.updatedAt;
      final tb = b.lastMessage?.createdAt ?? b.lastMessageAt ?? b.updatedAt;
      return tb.compareTo(ta);
    });
    return copy;
  }

  void _applyRoomUpdate(RoomUpdate update) {
    final idx = _rooms.indexWhere((r) => r.id == update.roomId);
    if (idx == -1) return;

    final old = _rooms[idx];
    final bumped = DiscussionRoom(
      id: old.id,
      topic: old.topic,
      description: old.description,
      isPublic: old.isPublic,
      createdBy: old.createdBy,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      lastMessageId: update.lastMessage.id,
      lastMessageAt: update.lastMessage.createdAt,
      lastMessage: update.lastMessage,
    );

    final next = [..._rooms]..removeAt(idx);
    next.insert(0, bumped);
    setState(() {
      _rooms = _sortRooms(next);
    });
  }

  Future<void> _onRefresh() => _fetchRooms();

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    return timeago.format(dt, locale: 'id');
  }

  String _preview(DiscussionMessage? m) {
    if (m == null) return 'Belum ada pesan';
    final who = (m.senderName ?? '').trim();
    final text = m.content.trim().isEmpty ? '(pesan kosong)' : m.content.trim();
    return who.isEmpty ? text : '$who: $text';
  }

  List<DiscussionRoom> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _rooms;
    return _rooms.where((r) {
      final t = r.topic.toLowerCase();
      final p = (r.lastMessage?.content ?? '').toLowerCase();
      return t.contains(q) || p.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // LISTEN REALTIME DI BUILD (AMAN UNTUK RIVERPOD)
    ref.listen<AsyncValue<RoomUpdate>>(roomUpdatesProvider, (prev, next) {
      next.whenData(_applyRoomUpdate);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0.5,
        titleSpacing: 16,
        title: const Text('Diskusi Publik'),
        actions: [
          IconButton(
            onPressed: _fetchRooms,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
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
              child: _loading
                  ? const _LoadingState()
                  : (_error != null
                  ? _ErrorState(message: _error!, onRetry: _fetchRooms)
                  : _ListView(
                rooms: _filtered,
                onRefresh: _onRefresh,
                itemBuilder: (room) => _RoomCard(
                  title: room.topic,
                  subtitle: _preview(room.lastMessage),
                  timeLabel: _relativeTime(
                    room.lastMessage?.createdAt ??
                        room.lastMessageAt ??
                        room.updatedAt,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiscussionRoomScreen(roomId: room.id),
                      ),
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
                hintText: 'Cari topik atau pesan…',
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
  final List<DiscussionRoom> rooms;
  final Future<void> Function() onRefresh;
  final Widget Function(DiscussionRoom) itemBuilder;

  const _ListView({
    required this.rooms,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => itemBuilder(rooms[i]),
      ),
    );
    // Catatan: pakai ListView biasa supaya ringan, kita mainkan estetika di kartu.
  }
}

class _RoomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeLabel;
  final VoidCallback onTap;

  const _RoomCard({
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

              // Waktu
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
                  // titik status kecil (opsional: selalu abu2 agar minimalis)
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
    // Simple skeleton-style tanpa lib tambahan
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
            const Icon(Icons.forum_outlined, size: 64, color: AppColors.primaryColor),
            const SizedBox(height: 10),
            Text(
              'Belum ada diskusi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai percakapan atau pilih room yang tersedia.',
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
