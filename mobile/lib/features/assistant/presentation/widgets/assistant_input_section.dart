import 'package:flutter/material.dart';

import 'assistant_character_counter.dart';
import 'assistant_input_container.dart';
import 'assistant_input_helper.dart';
import 'assistant_input_row.dart';

class AssistantInputSection extends StatelessWidget {
  const AssistantInputSection({
    required this.controller,
    required this.onSend,
    super.key,
    this.focusNode,
    this.hintText = 'Ask DayPilot anything...',
    this.enabled = true,
    this.isSending = false,
    this.maxLength = 2000,
    this.helperMessage =
        'AI can make mistakes. Review important actions before confirming.',
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;
  final String hintText;
  final bool enabled;
  final bool isSending;
  final int maxLength;
  final String helperMessage;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AssistantInputContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssistantInputRow(
            controller: controller,
            focusNode: focusNode,
            onSend: onSend,
            hintText: hintText,
            enabled: enabled,
            isSending: isSending,
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          AssistantInputHelper(
            message: helperMessage,
            trailing: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return AssistantCharacterCounter(
                  currentLength: value.text.length,
                  maxLength: maxLength,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
