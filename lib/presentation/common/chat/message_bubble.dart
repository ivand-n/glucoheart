import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/utils/url_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/discussion_message.dart';
import '../../providers/auth_provider.dart';

class MessageBubble extends ConsumerWidget {
  final DiscussionMessage message;
  final bool showAvatar;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isFromCurrentUser =
        currentUser != null && message.senderId.toString() == currentUser.id;

    final bubbleColor = isFromCurrentUser ? AppColors.primaryColor : Colors.white;
    final textColor = isFromCurrentUser ? Colors.white : AppColors.textPrimary;

    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.74;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
        isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser && showAvatar)
            _Avatar(avatarUrl: message.senderAvatar, name: message.senderName),

          if (!isFromCurrentUser && showAvatar) const SizedBox(width: 8),

          Flexible(
            child: Column(
              crossAxisAlignment:
              isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isFromCurrentUser &&
                    message.senderName != null &&
                    message.senderName!.trim().isNotEmpty &&
                    showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName!.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                // Bubble
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isFromCurrentUser
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isFromCurrentUser
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(color: textColor, height: 1.35, fontSize: 14.5),
                    ),
                  ),
                ),

                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 6, right: 6),
                    child: Text(
                      timeago.format(message.createdAt, locale: 'id'),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (isFromCurrentUser && showAvatar) const SizedBox(width: 8),

          if (isFromCurrentUser && showAvatar)
            _Avatar(avatarUrl: message.senderAvatar, name: message.senderName),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;

  const _Avatar({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(UrlUtils.full(avatarUrl!)),
      );
    }

    final String initial = _initialFrom(name);
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _initialFrom(String? displayName) {
    final s = (displayName ?? '').trim();
    if (s.isEmpty) return '?';
    return s.characters.first.toUpperCase();
  }
}
