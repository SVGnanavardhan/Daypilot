import 'package:flutter/material.dart';

import 'assistant_input_field.dart';
import 'assistant_send_button.dart';

class AssistantInputRow extends StatelessWidget {
  const AssistantInputRow({
    required this.controller,
    required this.onSend,
    super.key,
    this.focusNode,
    this.hintText = 'Ask DayPilot anything...',
    this.enabled = true,
    this.isSending = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;
  final String hintText;
  final bool enabled;
  final bool isSending;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final canSend = enabled && !isSending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AssistantInputField(
            controller: controller,
            focusNode: focusNode,
            hintText: hintText,
            enabled: enabled && !isSending,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        AssistantSendButton(
          onPressed: onSend,
          enabled: canSend,
          isLoading: isSending,
        ),
      ],
    );
  }
}
