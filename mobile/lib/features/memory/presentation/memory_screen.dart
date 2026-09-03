import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory_repository.dart';
import 'memory_controller.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(memoryControllerProvider);

    final controller = ref.read(
      memoryControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(
            _showAddDialog(
              context,
              controller,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Memory'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildBody(
            state,
            controller,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    MemoryState state,
    MemoryController controller,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 450,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            state.error!,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.psychology_alt_outlined,
            size: 56,
          ),
          SizedBox(height: 12),
          Text(
            'No saved memories yet.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Save useful information for your DayPilot assistant.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = state.items[index];

        return _MemoryCard(
          item: item,
          onDelete: () {
            unawaited(
              controller.deleteMemory(
                item.id,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    MemoryController controller,
  ) async {
    final titleController = TextEditingController();

    final contentController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Memory'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller: contentController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Information',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final title = titleController.text.trim();

                  final content = contentController.text.trim();

                  if (title.isEmpty || content.isEmpty) {
                    return;
                  }

                  await controller.addMemory(
                    title: title,
                    content: content,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(
                      dialogContext,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      titleController.dispose();
      contentController.dispose();
    }
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.item,
    required this.onDelete,
  });

  final MemoryItem item;
  final VoidCallback onDelete;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.lightbulb_outline,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(
          item.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
          ),
        ),
      ),
    );
  }
}
