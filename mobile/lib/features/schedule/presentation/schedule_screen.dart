import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/presentation/task_controller.dart';
import '../data/schedule_repository.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddScheduleDialog(
          repository: ref.read(scheduleRepositoryProvider),
          initialDay: _weekdayName(_selectedDate),
          onSaved: () {
            ref.invalidate(scheduleProvider);
          },
        );
      },
    );
  }

  Future<void> _deleteEntry(
    Map<String, dynamic> entry,
  ) async {
    final id = entry['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final title = entry['title']?.toString() ?? 'this entry';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Schedule Entry?'),
          content: Text('Delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(scheduleRepositoryProvider).deleteScheduleEntry(id);

      ref.invalidate(scheduleProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete schedule entry: $error',
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(scheduleProvider)
      ..invalidate(tasksStreamProvider);

    await ref.read(scheduleProvider.future);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDate = _dateOnly(picked);
    });
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(
        const Duration(days: 1),
      );
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(
        const Duration(days: 1),
      );
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = _dateOnly(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            tooltip: 'Today',
            onPressed: _goToToday,
            icon: const Icon(
              Icons.today_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref
                ..invalidate(scheduleProvider)
                ..invalidate(tasksStreamProvider);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _DateSelector(
            selectedDate: _selectedDate,
            onPrevious: _previousDay,
            onNext: _nextDay,
            onPickDate: _pickDate,
          ),
          const Divider(height: 1),
          Expanded(
            child: scheduleAsync.when(
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stackTrace) {
                return _ScheduleErrorView(
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(scheduleProvider);
                  },
                );
              },
              data: (entries) {
                return tasksAsync.when(
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (error, stackTrace) {
                    return _ScheduleErrorView(
                      message: error.toString(),
                      onRetry: () {
                        ref.invalidate(tasksStreamProvider);
                      },
                    );
                  },
                  data: (tasks) {
                    final selectedTasks = tasks
                        .where(
                          (task) =>
                              task.dueDate != null &&
                              _isSameDay(
                                task.dueDate!,
                                _selectedDate,
                              ),
                        )
                        .toList()
                      ..sort(
                        (first, second) {
                          final firstDate = first.dueDate!;
                          final secondDate = second.dueDate!;

                          return firstDate.compareTo(secondDate);
                        },
                      );

                    final selectedWeekday = _weekdayName(_selectedDate);

                    final selectedEntries = entries.where(
                      (entry) {
                        final day = entry['day_of_week']?.toString().trim();

                        return day != null &&
                            day.toLowerCase() == selectedWeekday.toLowerCase();
                      },
                    ).toList();

                    final hasContent =
                        selectedTasks.isNotEmpty || selectedEntries.isNotEmpty;

                    if (!hasContent) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.55,
                              child: _EmptyScheduleView(
                                selectedDate: _selectedDate,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          16,
                          12,
                          100,
                        ),
                        children: [
                          if (selectedTasks.isNotEmpty) ...[
                            const _ScheduleSectionTitle(
                              title: 'Tasks',
                              icon: Icons.task_alt_rounded,
                            ),
                            const SizedBox(height: 8),
                            ...selectedTasks.map(
                              (task) => _DueTaskCard(
                                task: task,
                                selectedDate: _selectedDate,
                              ),
                            ),
                          ],
                          if (selectedTasks.isNotEmpty &&
                              selectedEntries.isNotEmpty)
                            const SizedBox(height: 20),
                          if (selectedEntries.isNotEmpty) ...[
                            const _ScheduleSectionTitle(
                              title: 'Classes & Events',
                              icon: Icons.event_note_rounded,
                            ),
                            const SizedBox(height: 8),
                            ...selectedEntries.map(
                              (entry) {
                                final title = entry['title']?.toString();
                                final start = entry['start_time']?.toString();
                                final end = entry['end_time']?.toString();
                                final location = entry['location']?.toString();

                                final subtitleParts = <String>[
                                  if (start != null &&
                                      start.isNotEmpty &&
                                      end != null &&
                                      end.isNotEmpty)
                                    '${_displayTime(start)} - ${_displayTime(end)}',
                                  if (location != null &&
                                      location.trim().isNotEmpty)
                                    location.trim(),
                                ];

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.schedule_rounded,
                                    ),
                                    title: Text(
                                      title == null || title.trim().isEmpty
                                          ? 'Scheduled Event'
                                          : title.trim(),
                                    ),
                                    subtitle: subtitleParts.isEmpty
                                        ? null
                                        : Text(
                                            subtitleParts.join(' • '),
                                          ),
                                    trailing: IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        unawaited(
                                          _deleteEntry(entry),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'schedule_fab',
        onPressed: () {
          unawaited(_showAddDialog());
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  static bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static String _weekdayName(
    DateTime date,
  ) {
    const days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  static String _displayTime(
    String value,
  ) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    return '${parts[0]}:${parts[1]}';
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      isToday ? 'Today' : _weekdayName(selectedDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: onNext,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
          ),
        ],
      ),
    );
  }

  static String _weekdayName(
    DateTime date,
  ) {
    const days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _AddScheduleDialog extends StatefulWidget {
  const _AddScheduleDialog({
    required this.repository,
    required this.initialDay,
    required this.onSaved,
  });

  final ScheduleRepository repository;
  final String initialDay;
  final VoidCallback onSaved;

  @override
  State<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<_AddScheduleDialog> {
  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  late String _day;

  TimeOfDay _startTime = const TimeOfDay(
    hour: 9,
    minute: 0,
  );

  TimeOfDay _endTime = const TimeOfDay(
    hour: 10,
    minute: 0,
  );

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _day = widget.initialDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _startTime = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _endTime = picked;
    });
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title.'),
        ),
      );
      return;
    }

    if (_minutesOfDay(_endTime) <= _minutesOfDay(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'End time must be after start time.',
          ),
        ),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.repository.addScheduleEntry(
        title: title,
        dayOfWeek: _day,
        startTime: _timeToDb(_startTime),
        endTime: _timeToDb(_endTime),
        location: _nullableText(
          _locationController.text,
        ),
      );

      widget.onSaved();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
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
            'Unable to add schedule entry: $error',
          ),
        ),
      );
    }
  }

  static int _minutesOfDay(
    TimeOfDay time,
  ) {
    return (time.hour * 60) + time.minute;
  }

  static String _timeToDb(
    TimeOfDay time,
  ) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  static String? _nullableText(
    String value,
  ) {
    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        title: const Text('Add Class / Event'),
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
                  labelText: 'Title',
                  prefixIcon: Icon(
                    Icons.event_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _day,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: _days
                    .map(
                      (day) => DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _day = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              _TimePickerTile(
                label: 'Start Time',
                value: _startTime,
                enabled: !_isSaving,
                onTap: _pickStartTime,
              ),
              _TimePickerTile(
                label: 'End Time',
                value: _endTime,
                enabled: !_isSaving,
                onTap: _pickEndTime,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                  border: OutlineInputBorder(),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isSaving ? null : _saveEntry,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DueTaskCard extends StatelessWidget {
  const _DueTaskCard({
    required this.task,
    required this.selectedDate,
  });

  final Task task;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = task.dueDate!;

    final today = DateTime.now();

    final selectedIsToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    String status;

    if (task.isCompleted) {
      status = 'Completed';
    } else if (selectedIsToday) {
      status = 'Due today';
    } else {
      status = 'Due ${_formatDate(dueDate)}';
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle_rounded
              : Icons.task_alt_outlined,
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(status),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
      ),
    );
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _ScheduleSectionTitle extends StatelessWidget {
  const _ScheduleSectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final TimeOfDay value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.access_time_rounded,
      ),
      title: Text(label),
      subtitle: Text(
        value.format(context),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _EmptyScheduleView extends StatelessWidget {
  const _EmptyScheduleView({
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing scheduled',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks, classes, or events for '
              '${_formatDate(selectedDate)}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _ScheduleErrorView extends StatelessWidget {
  const _ScheduleErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
