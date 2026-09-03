class MemoryItem {
  const MemoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MemoryItem copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return MemoryItem(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

abstract class MemoryRepository {
  Future<List<MemoryItem>> getMemories();

  Future<void> saveMemory(MemoryItem memory);

  Future<void> updateMemory(MemoryItem memory);

  Future<void> deleteMemory(String id);

  Future<void> clearMemories();
}

class InMemoryMemoryRepository implements MemoryRepository {
  final List<MemoryItem> _items = <MemoryItem>[];

  @override
  Future<List<MemoryItem>> getMemories() async {
    final result = List<MemoryItem>.of(_items)
      ..sort(
        (a, b) =>
            (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt),
      );

    return List<MemoryItem>.unmodifiable(result);
  }

  @override
  Future<void> saveMemory(MemoryItem memory) async {
    _items.add(memory);
  }

  @override
  Future<void> updateMemory(MemoryItem memory) async {
    final index = _items.indexWhere(
      (item) => item.id == memory.id,
    );

    if (index == -1) {
      throw StateError('Memory not found.');
    }

    _items[index] = memory;
  }

  @override
  Future<void> deleteMemory(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearMemories() async {
    _items.clear();
  }
}
