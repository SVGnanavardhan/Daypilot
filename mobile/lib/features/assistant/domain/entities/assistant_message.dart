import 'package:equatable/equatable.dart';

enum AssistantMessageRole {
  user,
  assistant,
  system,
}

class AssistantMessage extends Equatable {
  const AssistantMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.isError = false,
  });

  final String id;
  final String content;
  final AssistantMessageRole role;
  final DateTime createdAt;
  final bool isError;

  bool get isUser => role == AssistantMessageRole.user;

  bool get isAssistant => role == AssistantMessageRole.assistant;

  AssistantMessage copyWith({
    String? id,
    String? content,
    AssistantMessageRole? role,
    DateTime? createdAt,
    bool? isError,
  }) {
    return AssistantMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        role,
        createdAt,
        isError,
      ];
}
