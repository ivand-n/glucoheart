// lib/presentation/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const ChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _secure = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // pastikan socket connect + join room + load awal
    final token = await _secure.read(key: 'auth_token');
    if (!mounted) return;

    if (token != null) {
      await ref.read(chatProvider.notifier).ensureSocketConnected(token: token);
    }
    await ref.read(chatProvider.notifier).joinSession(widget.sessionId);
    await ref.read(chatProvider.notifier).loadMessages(widget.sessionId);

    // auto scroll ke bawah
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    // ⬇️ LEAVE session agar server bersih
    ref.read(chatProvider.notifier).leaveSession(widget.sessionId);
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    final auth = ref.watch(authProvider);
    final myId = int.tryParse(auth.user?.id ?? '') ?? -1;

    final messages = chatState.messagesBySession[widget.sessionId] ?? const <ChatMessage>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.scaffoldBackground,
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isMe = m.senderId == myId;
                  return _MessageBubble(
                    message: m,
                    isMe: isMe,
                  );
                },
              ),
            ),
          ),
          _InputBar(
            controller: _controller,
            onSend: (txt) async {
              if (txt.trim().isEmpty) return;
              await ref.read(chatProvider.notifier).sendMessage(widget.sessionId, txt.trim());
              _controller.clear();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}

/// Input bar
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              width: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                onPressed: () => onSend(controller.text),
                child: const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bubble message dengan badge role utk pengirim bukan kita
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  Color _badgeColor(String role) {
    switch (role) {
      case 'ADMIN':
        return AppColors.primaryColor;
      case 'SUPPORT':
        return AppColors.info;
      case 'NURSE':
        return AppColors.secondaryColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _badgeLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'SUPPORT':
        return 'Support';
      case 'NURSE':
        return 'Nakes';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdLabel = timeago.format(message.createdAt, locale: 'id');

    // warna dan alignment
    final bg = isMe ? AppColors.primaryColor : Colors.white;
    final fg = isMe ? Colors.white : AppColors.textPrimary;
    final cross = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final align = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    // show badge kalau bukan kita & punya role spesifik
    final showBadge = !isMe && (message.senderRole == 'ADMIN' || message.senderRole == 'SUPPORT' || message.senderRole == 'NURSE');

    return Row(
      mainAxisAlignment: align,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                AppShadows.small,
              ],
            ),
            child: Column(
              crossAxisAlignment: cross,
              children: [
                if (showBadge || (!isMe && (message.senderName?.isNotEmpty ?? false))) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMe && (message.senderName?.isNotEmpty ?? false)) ...[
                        Text(
                          message.senderName!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isMe ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                      if (showBadge) ...[
                        if (!isMe && (message.senderName?.isNotEmpty ?? false))
                          const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withOpacity(0.25)
                                : _badgeColor(message.senderRole!).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMe
                                  ? Colors.white.withOpacity(0.35)
                                  : _badgeColor(message.senderRole!).withOpacity(0.35),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            _badgeLabel(message.senderRole!),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isMe ? Colors.white : _badgeColor(message.senderRole!),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                // content
                Text(
                  message.content,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                // time
                Text(
                  createdLabel,
                  style: TextStyle(
                    color: (isMe ? Colors.white : AppColors.textSecondary).withOpacity(isMe ? 0.85 : 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
