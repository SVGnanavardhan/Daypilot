import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _institutionController = TextEditingController();
  final _courseController = TextEditingController();
  final _departmentController = TextEditingController();
  final _semesterController = TextEditingController();
  final _careerGoalController = TextEditingController();

  TimeOfDay _collegeStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _collegeEnd = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  double _studyMinutes = 45;

  bool _loading = true;
  bool _saving = false;

  bool get _isBusy => _loading || _saving;

  @override
  void initState() {
    super.initState();

    unawaited(
      _loadProfile(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _courseController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _careerGoalController.dispose();

    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();

      if (!mounted) {
        return;
      }

      if (profile != null) {
        _nameController.text = profile['name']?.toString() ?? '';
        _institutionController.text = profile['institution']?.toString() ?? '';
        _courseController.text = profile['course']?.toString() ?? '';
        _departmentController.text = profile['department']?.toString() ?? '';
        _semesterController.text = profile['semester']?.toString() ?? '';
        _careerGoalController.text = profile['career_goal']?.toString() ?? '';

        _collegeStart = _timeFromDb(
          profile['college_start_time']?.toString(),
          const TimeOfDay(hour: 9, minute: 0),
        );

        _collegeEnd = _timeFromDb(
          profile['college_end_time']?.toString(),
          const TimeOfDay(hour: 16, minute: 0),
        );

        _wakeTime = _timeFromDb(
          profile['wake_time']?.toString(),
          const TimeOfDay(hour: 6, minute: 30),
        );

        _sleepTime = _timeFromDb(
          profile['sleep_time']?.toString(),
          const TimeOfDay(hour: 23, minute: 0),
        );

        final preferredMinutes = profile['preferred_study_minutes'];

        final parsedMinutes = double.tryParse(
          preferredMinutes?.toString() ?? '',
        );

        if (parsedMinutes != null) {
          _studyMinutes = parsedMinutes.clamp(15.0, 120.0);
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load profile: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  TimeOfDay _timeFromDb(
    String? value,
    TimeOfDay fallback,
  ) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return fallback;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return fallback;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  String _timeToDb(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  int _minutesFromMidnight(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  Future<void> _selectTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    if (_isBusy) {
      return;
    }

    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (!mounted || selected == null) {
      return;
    }

    onSelected(selected);
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (_saving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_minutesFromMidnight(_collegeEnd) <=
        _minutesFromMidnight(_collegeStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'College end time must be after college start time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref.read(profileRepositoryProvider).saveProfile(
            name: _nameController.text.trim(),
            institution: _institutionController.text.trim(),
            course: _courseController.text.trim(),
            department: _departmentController.text.trim(),
            semester: _semesterController.text.trim(),
            careerGoal: _careerGoalController.text.trim(),
            collegeStartTime: _timeToDb(_collegeStart),
            collegeEndTime: _timeToDb(_collegeEnd),
            wakeTime: _timeToDb(_wakeTime),
            sleepTime: _timeToDb(_sleepTime),
            preferredStudyMinutes: _studyMinutes.round(),
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save profile: $error',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isBusy,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }

              return null;
            }
          : null,
    );
  }

  Widget _buildTimeTile({
    required String label,
    required TimeOfDay value,
    required IconData icon,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return Card(
      child: ListTile(
        enabled: !_isBusy,
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value.format(context),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: _isBusy
            ? null
            : () {
                unawaited(
                  _selectTime(
                    initial: value,
                    onSelected: onChanged,
                  ),
                );
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            tooltip: 'Reload profile',
            onPressed: _saving ? null : _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Academic Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      requiredField: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _institutionController,
                      label: 'College / Institution',
                      icon: Icons.school_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _courseController,
                      label: 'Course',
                      icon: Icons.menu_book_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _departmentController,
                      label: 'Department',
                      icon: Icons.account_tree_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _semesterController,
                      label: 'Semester',
                      icon: Icons.timeline_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _careerGoalController,
                      label: 'Career Goal',
                      icon: Icons.flag_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Daily Routine',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimeTile(
                      label: 'College Start',
                      value: _collegeStart,
                      icon: Icons.login_rounded,
                      onChanged: (value) {
                        setState(() {
                          _collegeStart = value;
                        });
                      },
                    ),
                    _buildTimeTile(
                      label: 'College End',
                      value: _collegeEnd,
                      icon: Icons.logout_rounded,
                      onChanged: (value) {
                        setState(() {
                          _collegeEnd = value;
                        });
                      },
                    ),
                    _buildTimeTile(
                      label: 'Wake Time',
                      value: _wakeTime,
                      icon: Icons.wb_sunny_outlined,
                      onChanged: (value) {
                        setState(() {
                          _wakeTime = value;
                        });
                      },
                    ),
                    _buildTimeTile(
                      label: 'Sleep Time',
                      value: _sleepTime,
                      icon: Icons.bedtime_outlined,
                      onChanged: (value) {
                        setState(() {
                          _sleepTime = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Preferred Study Session'),
                        ),
                        Text(
                          '${_studyMinutes.round()} min',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _studyMinutes,
                      min: 15,
                      max: 120,
                      divisions: 7,
                      label: '${_studyMinutes.round()} min',
                      onChanged: _isBusy
                          ? null
                          : (value) {
                              setState(() {
                                _studyMinutes = value;
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: _saving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Saving...' : 'Save Profile',
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
