import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../catalog/domain/models.dart';

abstract interface class ProgressRepository {
  Map<String, ProgressEntry> readAll();
  Future<void> write(String id, ProgressEntry entry);
  Future<void> writeAll(Map<String, ProgressEntry> entries);
  Future<void> clear();
}

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository(this.box);
  final Box<String> box;
  static const storageVersionKey = '_storage_version';

  @override
  Map<String, ProgressEntry> readAll() {
    final result = <String, ProgressEntry>{};
    for (final key in box.keys.whereType<String>()) {
      if (key.startsWith('_')) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        final value = jsonDecode(raw);
        if (value is Map<String, dynamic>) {
          result[key] = ProgressEntry.fromJson(value);
        }
      } on FormatException {
        continue;
      }
    }
    return result;
  }

  @override
  Future<void> write(String id, ProgressEntry entry) =>
      box.put(id, jsonEncode(entry.toJson()));

  @override
  Future<void> writeAll(Map<String, ProgressEntry> entries) => box.putAll({
    for (final item in entries.entries)
      item.key: jsonEncode(item.value.toJson()),
  });

  @override
  Future<void> clear() async {
    final keys = box.keys
        .whereType<String>()
        .where((key) => !key.startsWith('_'))
        .toList();
    await box.deleteAll(keys);
  }
}

class MemoryProgressRepository implements ProgressRepository {
  final Map<String, ProgressEntry> values = {};
  @override
  Map<String, ProgressEntry> readAll() => Map.unmodifiable(values);
  @override
  Future<void> write(String id, ProgressEntry entry) async {
    values[id] = entry;
  }

  @override
  Future<void> writeAll(Map<String, ProgressEntry> entries) async {
    values.addAll(entries);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }
}
