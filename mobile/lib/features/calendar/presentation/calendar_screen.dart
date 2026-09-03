import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_controller.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadDay(state.selectedDay),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CalendarDatePicker(
                initialDate: state.selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                onDateChanged: controller.selectDay,
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Unable to load calendar: ${state.error}',
                    ),
                  ),
                )
              else if (state.entries.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.event_available_rounded, size: 36),
                        SizedBox(height: 10),
                        Text(
                          'No calendar entries for this day.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...state.entries.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_rounded),
                      title: Text(entry.title),
                      subtitle: entry.description == null
                          ? Text(_formatRange(entry.start, entry.end))
                          : Text(
                              '${_formatRange(entry.start, entry.end)}\n'
                              '${entry.description}',
                            ),
                      isThreeLine: entry.description != null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatRange(DateTime start, DateTime end) {
    String time(DateTime value) {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${time(start)} - ${time(end)}';
  }
}
