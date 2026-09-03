import 'package:flutter/material.dart';

class AssistantFeedbackSheet extends StatefulWidget {
  const AssistantFeedbackSheet({
    required this.onSubmit,
    super.key,
    this.title = 'Share feedback',
  });

  final ValueChanged<String> onSubmit;
  final String title;

  @override
  State<AssistantFeedbackSheet> createState() => _AssistantFeedbackSheetState();
}

class _AssistantFeedbackSheetState extends State<AssistantFeedbackSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final feedback = _controller.text.trim();

    if (feedback.isEmpty) {
      return;
    }

    widget.onSubmit(feedback);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tell us what worked well or what DayPilot could improve.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submit,
              child: const Text('Submit feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
