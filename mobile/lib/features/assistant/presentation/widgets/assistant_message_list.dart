import 'package:flutter/material.dart';

import '../../domain/entities/assistant_message.dart';
import 'assistant_message_bubble.dart';

class AssistantMessageList extends StatelessWidget {
  const AssistantMessageList({
    required this.messages,
    required this.scrollController,
    super.key,
  });

  final List<AssistantMessage> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return AssistantMessageBubble(
          message: messages[index],
        );
      },
    );
  }
}
