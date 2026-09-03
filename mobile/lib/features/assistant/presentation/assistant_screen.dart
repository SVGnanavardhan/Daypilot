import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'assistant_controller.dart';
import 'widgets/assistant_empty_messages_view.dart';
import 'widgets/assistant_input_section.dart';
import 'widgets/assistant_message_bubble.dart';
import 'widgets/assistant_typing_indicator.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({
    super.key,
  });

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    _messageController.clear();

    await ref
        .read(
          assistantControllerProvider.notifier,
        )
        .sendMessage(message);

    _scrollToBottom();
  }

  void _usePrompt(String prompt) {
    _messageController
      ..text = prompt
      ..selection = TextSelection.collapsed(
        offset: prompt.length,
      );

    _messageFocusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!_scrollController.hasClients) {
          return;
        }

        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      },
    );
  }

  Future<void> _clearConversation() async {
    await ref
        .read(
          assistantControllerProvider.notifier,
        )
        .clearConversation();
  }

  @override
  Widget build(BuildContext context) {
    final assistantState = ref.watch(
      assistantControllerProvider,
    );

    ref.listen<AssistantState>(
      assistantControllerProvider,
      (previous, next) {
        if (previous?.messages.length != next.messages.length) {
          _scrollToBottom();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DayPilot Assistant',
        ),
        actions: [
          if (assistantState.hasMessages)
            IconButton(
              tooltip: 'Clear conversation',
              onPressed: assistantState.isLoading ? null : _clearConversation,
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildConversation(
                assistantState,
              ),
            ),
            if (assistantState.isLoading) const AssistantTypingIndicator(),
            AssistantInputSection(
              controller: _messageController,
              focusNode: _messageFocusNode,
              enabled: !assistantState.isLoading,
              isSending: assistantState.isLoading,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation(
    AssistantState state,
  ) {
    if (state.isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.messages.isEmpty) {
      return AssistantEmptyMessagesView(
        actionLabel: 'Plan my day',
        onAction: () {
          _usePrompt(
            'Help me plan my day',
          );
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),
      itemCount: state.messages.length,
      itemBuilder: (
        context,
        index,
      ) {
        return AssistantMessageBubble(
          message: state.messages[index],
        );
      },
    );
  }
}
