import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/themes/app_theme.dart';
import '../../../utils/logger.dart';
import '../../providers/discussion_provider.dart';

class MessageInput extends ConsumerStatefulWidget {
  final int roomId;
  final FocusNode? focusNode;
  final VoidCallback? onMessageSent;

  const MessageInput({
    Key? key,
    required this.roomId,
    this.focusNode,
    this.onMessageSent,
  }) : super(key: key);

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan tidak boleh kosong'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (content.length > 4000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan tidak boleh melebihi 4000 karakter'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Logger.d('Attempting to send message: "$content"', tag: 'MessageInput');

    try {
      await ref.read(messageInputProvider.notifier).sendMessage(
        widget.roomId,
        content,
      );

      Logger.d('Message sent successfully', tag: 'MessageInput');
      _textController.clear();
      if (widget.onMessageSent != null) {
        widget.onMessageSent!();
      }
    } catch (e) {
      Logger.e('Error sending message', tag: 'MessageInput', error: e);
      // Error will be displayed via messageInputProvider
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(messageInputProvider);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inputState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inputState.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 16,
                    ),
                    onPressed: () {
                      ref.read(messageInputProvider.notifier).clearError();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !inputState.isSending,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: inputState.isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: inputState.isSending ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}