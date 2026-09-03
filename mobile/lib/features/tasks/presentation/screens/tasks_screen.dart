import 'package:flutter/material.dart';

/// Lightweight tasks placeholder.
///
/// The complete task implementation exists in
/// `lib/features/tasks/presentation/tasks_screen.dart`.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _TaskFilter _selectedFilter = _TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Filter tasks',
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Sort tasks',
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TaskFilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: _TaskList(
                onTaskTap: (_) {},
                onTaskToggle: (_) {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

enum _TaskFilter {
  all,
  today,
  upcoming,
  completed,
}

class _TaskFilterBar extends StatelessWidget {
  const _TaskFilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _TaskFilter selectedFilter;
  final ValueChanged<_TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _TaskFilter.values.map(
            (filter) {
              final isSelected = selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                ),
                child: FilterChip(
                  label: Text(
                    _getFilterLabel(filter),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onFilterChanged(filter);
                    }
                  },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  String _getFilterLabel(_TaskFilter filter) {
    switch (filter) {
      case _TaskFilter.all:
        return 'All';

      case _TaskFilter.today:
        return 'Today';

      case _TaskFilter.upcoming:
        return 'Upcoming';

      case _TaskFilter.completed:
        return 'Completed';
    }
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.onTaskTap,
    required this.onTaskToggle,
  });

  final ValueChanged<Object?> onTaskTap;
  final ValueChanged<bool?> onTaskToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            onTap: () {
              onTaskTap(null);
            },
            leading: Checkbox(
              value: false,
              onChanged: onTaskToggle,
            ),
            title: const Text('No tasks yet'),
            subtitle: const Text(
              'Tap + to add your first task',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onTaskTap(null);
              },
            ),
          ),
        ),
      ],
    );
  }
}
