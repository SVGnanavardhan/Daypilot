import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/schedule_repository.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();

    var day = 'Monday';
    var startTime = const TimeOfDay(hour: 9, minute: 0);
    var endTime = const TimeOfDay(hour: 10, minute: 0);

    var isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isSaving,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {
              Future<void> saveEntry() async {
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a title.',
                      ),
                    ),
                  );

                  return;
                }

                if (_minutesOfDay(endTime) <= _minutesOfDay(startTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'End time must be after start time.',
                      ),
                    ),
                  );

                  return;
                }

                if (isSaving) {
                  return;
                }

                setDialogState(() {
                  isSaving = true;
                });

                try {
                  await ref.read(scheduleRepositoryProvider).addScheduleEntry(
                        title: title,
                        dayOfWeek: day,
                        startTime: _timeToDb(startTime),
                        endTime: _timeToDb(endTime),
                        location: _nullableText(
                          locationController.text,
                        ),
                      );

                  ref.invalidate(scheduleProvider);

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (error) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  setDialogState(() {
                    isSaving = false;
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

              return AlertDialog(
                title: const Text(
                  'Add Class / Event',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        enabled: !isSaving,
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
                        initialValue: day,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: _days
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  day = value;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      _TimePickerTile(
                        label: 'Start Time',
                        value: startTime,
                        enabled: !isSaving,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
                            initialTime: startTime,
                          );

                          if (picked != null) {
                            setDialogState(() {
                              startTime = picked;
                            });
                          }
                        },
                      ),
                      _TimePickerTile(
                        label: 'End Time',
                        value: endTime,
                        enabled: !isSaving,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
                            initialTime: endTime,
                          );

                          if (picked != null) {
                            setDialogState(() {
                              endTime = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        enabled: !isSaving,
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
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.of(
                              dialogContext,
                            ).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isSaving ? null : saveEntry,
                    child: isSaving
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
              );
            },
          );
        },
      );
    } finally {
      titleController.dispose();
      locationController.dispose();
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
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
          title: const Text(
            'Delete Schedule Entry?',
          ),
          content: Text(
            'Delete "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  true,
                );
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
      if (!context.mounted) {
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

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(scheduleProvider);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: scheduleAsync.when(
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
          if (entries.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(scheduleProvider);

                await ref.read(
                  scheduleProvider.future,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: const _EmptyScheduleView(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scheduleProvider);

              await ref.read(
                scheduleProvider.future,
              );
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                100,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                final title = entry['title']?.toString();

                final day = entry['day_of_week']?.toString();

                final start = entry['start_time']?.toString();

                final end = entry['end_time']?.toString();

                final location = entry['location']?.toString();

                final subtitleParts = <String>[
                  if (day != null && day.isNotEmpty) day,
                  if (start != null &&
                      start.isNotEmpty &&
                      end != null &&
                      end.isNotEmpty)
                    '${_displayTime(start)} - ${_displayTime(end)}',
                  if (location != null && location.trim().isNotEmpty)
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
                    subtitle: Text(
                      subtitleParts.join(' • '),
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        unawaited(
                          _deleteEntry(
                            context,
                            ref,
                            entry,
                          ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(
            _showAddDialog(
              context,
              ref,
            ),
          );
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text('Add'),
      ),
    );
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

  static String _displayTime(
    String value,
  ) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    return '${parts[0]}:${parts[1]}';
  }

  static String? _nullableText(
    String value,
  ) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
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
  const _EmptyScheduleView();

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
              'No classes or events yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your college timetable, study sessions, or personal events.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
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
