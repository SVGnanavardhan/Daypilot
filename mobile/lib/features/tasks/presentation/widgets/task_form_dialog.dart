import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_repository.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  const TaskFormDialog({
    super.key,
  });

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _subjectController = TextEditingController();

  String _priority = 'Medium';
  double _duration = 30;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 3650),
      ),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(taskRepositoryProvider).createTask(
            title: title,
            description: _nullableText(
              _descriptionController.text,
            ),
            subject: _nullableText(
              _subjectController.text,
            ),
            priority: _priority,
            estimatedDuration: _duration.round(),
            dueDate: _dueDate,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create task: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              enabled: !_isSaving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Estimated Duration',
                ),
                const Spacer(),
                Text(
                  '${_duration.round()} min',
                ),
              ],
            ),
            Slider(
              value: _duration,
              min: 15,
              max: 180,
              divisions: 11,
              label: '${_duration.round()} min',
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _duration = value;
                      });
                    },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_outlined,
              ),
              title: Text(
                _dueDate == null ? 'Add Due Date' : _formatDate(_dueDate!),
              ),
              trailing: _dueDate == null
                  ? const Icon(
                      Icons.chevron_right,
                    )
                  : IconButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
              onTap: _isSaving ? null : _pickDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save Task'),
        ),
      ],
    );
  }

  static String? _nullableText(
    String value,
  ) {
    final result = value.trim();

    return result.isEmpty ? null : result;
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
