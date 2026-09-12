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
  TimeOfDay? _dueTime;

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

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final initialDate =
        _dueDate != null && !_dueDate!.isBefore(today) ? _dueDate! : today;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: now.add(
        const Duration(days: 3650),
      ),
    );

    if (!mounted || date == null) {
      return;
    }

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
      );

      _dueTime ??= TimeOfDay.fromDateTime(
        DateTime.now().add(
          const Duration(hours: 1),
        ),
      );
    });
  }

  Future<void> _pickTime() async {
    if (_dueDate == null) {
      await _pickDate();

      if (_dueDate == null || !mounted) {
        return;
      }
    }

    final now = DateTime.now();

    final initialTime = _dueTime ??
        TimeOfDay.fromDateTime(
          now.add(
            const Duration(hours: 1),
          ),
        );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _dueTime = picked;
    });
  }

  void _clearDueDate() {
    if (_isSaving) {
      return;
    }

    setState(() {
      _dueDate = null;
      _dueTime = null;
    });
  }

  DateTime? _buildDueDateTime() {
    final date = _dueDate;

    if (date == null) {
      return null;
    }

    final time = _dueTime;

    if (time == null) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
      );
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _isSaving) {
      return;
    }

    final dueDateTime = _buildDueDateTime();

    if (dueDateTime != null && !dueDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Due date and time must be in the future.',
          ),
        ),
      );

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
            dueDate: dueDateTime,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        title: const Text(
          'Add Task',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(
                    Icons.task_alt_outlined,
                  ),
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
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(
                    Icons.book_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(
                    Icons.flag_outlined,
                  ),
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
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _priority = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today_outlined,
                ),
                title: const Text(
                  'Due Date',
                ),
                subtitle: Text(
                  _dueDate == null ? 'Not set' : _formatDate(_dueDate!),
                ),
                trailing: _dueDate == null
                    ? const Icon(
                        Icons.chevron_right_rounded,
                      )
                    : IconButton(
                        tooltip: 'Remove due date',
                        onPressed: _isSaving ? null : _clearDueDate,
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                onTap: _isSaving ? null : _pickDate,
              ),
              if (_dueDate != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.access_time_rounded,
                  ),
                  title: const Text(
                    'Due Time',
                  ),
                  subtitle: Text(
                    _dueTime == null
                        ? 'Select time'
                        : _dueTime!.format(
                            context,
                          ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                  onTap: _isSaving ? null : _pickTime,
                ),
              if (_dueDate != null && _dueTime != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(
                            child: Text(
                              'DayPilot will automatically remind you 30 minutes before the due time.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            child: const Text(
              'Cancel',
            ),
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
                : const Text(
                    'Save Task',
                  ),
          ),
        ],
      ),
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
