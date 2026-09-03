// ignore_for_file: avoid_positional_boolean_parameters, cascade_invocations, discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/task_repository.dart';
import 'task_controller.dart';
import 'widgets/task_form_dialog.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<DateTime?> _pickDueDate(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate != null &&
              !initialDate.isBefore(
                DateTime(now.year, now.month, now.day),
              )
          ? initialDate
          : now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 3650),
      ),
    );
  }

  Future<void> _showAddTaskDialog(
    BuildContext context,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return const TaskFormDialog();
      },
    );
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final titleController = TextEditingController(
      text: task.title,
    );

    final descriptionController = TextEditingController(
      text: task.description ?? '',
    );

    var selectedDueDate = task.dueDate;
    var isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> updateTask() async {
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a task title.',
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
                  await ref.read(taskRepositoryProvider).updateTask(
                        id: task.id,
                        title: title,
                        description: _nullableText(
                          descriptionController.text,
                        ),
                        priority: 'Medium',
                        estimatedDuration: 30,
                        dueDate: selectedDueDate,
                      );

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
                        'Unable to update task: $error',
                      ),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: const Text('Edit Task'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
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
                        controller: descriptionController,
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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                        ),
                        title: Text(
                          selectedDueDate == null
                              ? 'Add Due Date'
                              : 'Due ${_formatDate(selectedDueDate!)}',
                        ),
                        trailing: selectedDueDate == null
                            ? const Icon(
                                Icons.chevron_right_rounded,
                              )
                            : IconButton(
                                tooltip: 'Remove due date',
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          selectedDueDate = null;
                                        });
                                      },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              ),
                        onTap: isSaving
                            ? null
                            : () async {
                                final picked = await _pickDueDate(
                                  dialogContext,
                                  initialDate: selectedDueDate,
                                );

                                if (picked != null) {
                                  setDialogState(() {
                                    selectedDueDate = picked;
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isSaving ? null : updateTask,
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Update Task'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: Text(
            'Delete "${task.title}"?',
          ),
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

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref.read(taskRepositoryProvider).deleteTask(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete task: $error',
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
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Sync Tasks',
            onPressed: () {
              ref.invalidate(taskSyncProvider);
            },
            icon: const Icon(
              Icons.sync_rounded,
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _TasksErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(taskSyncProvider);
              ref.invalidate(tasksStreamProvider);
            },
          );
        },
        data: (tasks) {
          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(taskRepositoryProvider).syncFromSupabase();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: const _EmptyTasksView(),
                  ),
                ],
              ),
            );
          }

          final pendingTasks = tasks
              .where(
                (task) => !task.isCompleted,
              )
              .toList();

          final completedTasks = tasks
              .where(
                (task) => task.isCompleted,
              )
              .toList();

          final orderedTasks = [
            ...pendingTasks,
            ...completedTasks,
          ];

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(taskRepositoryProvider).syncFromSupabase();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                100,
              ),
              itemCount: orderedTasks.length,
              itemBuilder: (context, index) {
                final task = orderedTasks[index];

                return _TaskCard(
                  task: task,
                  onToggle: (value) async {
                    try {
                      await ref
                          .read(taskRepositoryProvider)
                          .toggleTaskCompletion(
                            task.id,
                            value,
                          );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to update task: $error',
                          ),
                        ),
                      );
                    }
                  },
                  onEdit: () {
                    _showEditTaskDialog(
                      context,
                      ref,
                      task,
                    );
                  },
                  onDelete: () {
                    _confirmDeleteTask(
                      context,
                      ref,
                      task,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text('Add Task'),
      ),
    );
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

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final Future<void> Function(bool value) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = task.dueDate;

    final isOverdue = dueDate != null &&
        !task.isCompleted &&
        dueDate.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value != null) {
              onToggle(value);
            }
          },
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_outlined,
                      size: 14,
                      color: isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOverdue
                          ? 'Overdue • ${TasksScreen._formatDate(dueDate)}'
                          : 'Due ${TasksScreen._formatDate(dueDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue ? theme.colorScheme.error : null,
                        fontWeight: isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView();

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
              Icons.task_alt_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task and DayPilot will help organize your day.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksErrorView extends StatelessWidget {
  const _TasksErrorView({
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
              'Unable to load tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
