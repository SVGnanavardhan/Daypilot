import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/error/exceptions.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) {
    final supabase = ref.watch(supabaseClientProvider);

    return ProfileRepository(supabase);
  },
  name: 'profileRepositoryProvider',
);

class ProfileRepository {
  ProfileRepository(this._supabase);

  final SupabaseClient _supabase;

  String? get _userId => _supabase.auth.currentUser?.id;

  String _requireUserId() {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      throw const AppAuthException(
        message: 'You must be logged in to access your profile.',
        code: 'NO_USER',
      );
    }

    return userId;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      return null;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } on PostgrestException catch (error) {
      throw ServerException(
        message: error.message,
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      if (error is ServerException) {
        rethrow;
      }

      throw ServerException(
        message: 'Unable to load your profile.',
        code: 'PROFILE_LOAD_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> saveProfile({
    required String name,
    required String institution,
    required String course,
    required String department,
    required String semester,
    required String careerGoal,
    required String collegeStartTime,
    required String collegeEndTime,
    required String wakeTime,
    required String sleepTime,
    required int preferredStudyMinutes,
  }) async {
    final userId = _requireUserId();

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw const ValidationException(
        message: 'Name cannot be empty.',
        code: 'INVALID_NAME',
      );
    }

    if (preferredStudyMinutes < 15 ||
        preferredStudyMinutes > 120) {
      throw const ValidationException(
        message:
            'Preferred study session must be between 15 and 120 minutes.',
        code: 'INVALID_STUDY_DURATION',
      );
    }

    try {
      await _supabase.from('profiles').upsert(
        {
          'id': userId,
          'name': trimmedName,
          'institution': institution.trim(),
          'course': course.trim(),
          'department': department.trim(),
          'semester': semester.trim(),
          'career_goal': careerGoal.trim(),
          'college_start_time': collegeStartTime,
          'college_end_time': collegeEndTime,
          'wake_time': wakeTime,
          'sleep_time': sleepTime,
          'preferred_study_minutes': preferredStudyMinutes,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error) {
      throw ServerException(
        message: error.message,
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      if (error is AppAuthException ||
          error is ValidationException ||
          error is ServerException) {
        rethrow;
      }

      throw ServerException(
        message: 'Unable to save your profile.',
        code: 'PROFILE_SAVE_FAILED',
        originalError: error,
      );
    }
  }
}
