/// Common type definitions used across DayPilot.
///
/// Keeping frequently used complex types here improves readability
/// and keeps feature-layer APIs consistent.
library;

/// Standard JSON object representation.
typedef JsonMap = Map<String, dynamic>;

/// Standard JSON list representation.
typedef JsonList = List<JsonMap>;

/// Asynchronous operation that returns no value.
typedef AsyncVoidCallback = Future<void> Function();
