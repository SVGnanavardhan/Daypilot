// ignore_for_file: avoid_positional_boolean_parameters, discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/task_repository.dart';
import 'task_controller.dart';
import 'widgets/task_form_dialog.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _EditTaskDialog(
          task: task,
          repository: ref.read(
            taskRepositoryProvider,
          ),
        );
      },
    );
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
              ref
                ..invalidate(taskSyncProvider)
                ..invalidate(tasksStreamProvider);
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
        heroTag: 'tasks_fab',
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

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _EditTaskDialog extends StatefulWidget {
  const _EditTaskDialog({
    required this.task,
    required this.repository,
  });

  final Task task;
  final TaskRepository repository;

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _selectedDueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task.title,
    );

    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );

    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _pickDueDate() async {
    if (_isSaving) {
      return;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final initialDate =
        _selectedDueDate != null && !_selectedDueDate!.isBefore(today)
            ? _selectedDueDate!
            : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: now.add(
        const Duration(days: 3650),
      ),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDueDate = picked;
    });
  }

  Future<void> _updateTask() async {
    final title = _titleController.text.trim();

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

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.repository.updateTask(
        id: widget.task.id,
        title: title,
        description: _nullableText(
          _descriptionController.text,
        ),
        priority: 'Medium',
        estimatedDuration: 30,
        dueDate: _selectedDueDate,
      );

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
            'Unable to update task: $error',
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Task',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              enabled: !_isSaving,
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_outlined,
              ),
              title: Text(
                _selectedDueDate == null
                    ? 'Add Due Date'
                    : 'Due ${TasksScreen._formatDate(_selectedDueDate!)}',
              ),
              trailing: _selectedDueDate == null
                  ? const Icon(
                      Icons.chevron_right_rounded,
                    )
                  : IconButton(
                      tooltip: 'Remove due date',
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
              onTap: _isSaving ? null : _pickDueDate,
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
          onPressed: _isSaving ? null : _updateTask,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Update Task',
                ),
        ),
      ],
    );
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
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final isOverdue =
        dueDate != null && !task.isCompleted && dueDate.isBefore(today);

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
                padding: const EdgeInsets.only(
                  top: 4,
                ),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (dueDate != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                ),
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

              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                    ),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                    ),
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
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
