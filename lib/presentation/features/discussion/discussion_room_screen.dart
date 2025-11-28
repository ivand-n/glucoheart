import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/utils/logger.dart';
import '../../../domain/entities/discussion_message.dart';
import '../../providers/discussion_provider.dart';
import '../../common/chat/chat_list.dart';
import '../../common/chat/message_input.dart';

class DiscussionRoomScreen extends ConsumerStatefulWidget {
  final int roomId;

  const DiscussionRoomScreen({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<DiscussionRoomScreen> createState() => _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends ConsumerState<DiscussionRoomScreen> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  List<DiscussionMessage> _messages = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectToRoom();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentRoomIdProvider.notifier).state = widget.roomId;
    });
  }

  Future<void> _connectToRoom() async {
    try {
      setState(() => _isConnected = false);
      final repository = ref.read(discussionRepositoryProvider);
      await repository.connectToRoom(widget.roomId);
      setState(() => _isConnected = true);
    } catch (e) {
      Logger.e('Failed to connect to room', tag: 'DiscussionRoom', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung: ${e.toString()}'),
          action: SnackBarAction(label: 'Coba Lagi', onPressed: _connectToRoom),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    ref.read(currentRoomIdProvider.notifier).state = null;
    ref.read(discussionRepositoryProvider).disconnectFromRoom();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(discussionRepositoryProvider);
      final messages = await repository.fetchMessages(widget.roomId);
      setState(() {
        _messages = messages; // urutan kronologis (lama -> baru)
        _isLoading = false;
      });

      // Scroll ke paling bawah setelah data masuk
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(immediate: true);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.position.maxScrollExtent;
    if (immediate) {
      _scrollController.jumpTo(offset);
    } else {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DENGARKAN STREAM realtime
    ref.listen<AsyncValue<DiscussionMessage>>(
      messageStreamProvider(widget.roomId),
          (previous, next) {
        next.whenData((message) {
          setState(() {
            // tambahkan bila belum ada
            if (!_messages.any((m) => m.id == message.id)) {
              _messages = [..._messages, message];
            }
          });
          // scroll ke bawah untuk menampilkan pesan baru
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        });
      },
    );

    final roomsAsync = ref.watch(discussionRoomsProvider);
    final roomName = roomsAsync.whenOrNull(
      data: (rooms) => rooms.firstWhere(
            (r) => r.id == widget.roomId,
        orElse: () => rooms.first,
      ).topic,
    ) ??
        'Loading...';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(roomName),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Terhubung' : 'Terputus',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMessages();
              _connectToRoom();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              messages: _messages,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              scrollController: _scrollController,
              onRefresh: _loadMessages,
            ),
          ),
          MessageInput(
            roomId: widget.roomId,
            focusNode: _focusNode,
            onMessageSent: () {
              // Begitu pesan terkirim, langsung scroll paling bawah
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
