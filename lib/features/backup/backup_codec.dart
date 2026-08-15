import 'dart:convert';
import '../catalog/domain/models.dart';

class BackupCodec {
  const BackupCodec();
  static const format = 'fornai-checklist-progress';
  static const schemaVersion = 1;

  String encode({
    required String catalogVersion,
    required Map<String, ProgressEntry> entries,
    DateTime? exportedAt,
  }) => const JsonEncoder.withIndent('  ').convert({
    'format': format,
    'schemaVersion': schemaVersion,
    'catalogVersion': catalogVersion,
    'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
    'entries': {
      for (final item in entries.entries) item.key: item.value.toJson(),
    },
  });

  Map<String, ProgressEntry> decode(
    String source, {
    required Set<String> knownVariantIds,
  }) {
    if (source.length > 1000000) {
      throw const FormatException('O backup excede o tamanho permitido.');
    }
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != format ||
        decoded['schemaVersion'] != schemaVersion) {
      throw const FormatException('Formato ou versão de backup incompatível.');
    }
    if (DateTime.tryParse(decoded['exportedAt'] as String? ?? '') == null) {
      throw const FormatException('Data de exportação inválida.');
    }
    final rawEntries = decoded['entries'];
    if (rawEntries is! Map<String, dynamic>) {
      throw const FormatException('Lista de progresso inválida.');
    }
    final result = <String, ProgressEntry>{};
    for (final item in rawEntries.entries) {
      if (!knownVariantIds.contains(item.key)) continue;
      if (item.value is! Map<String, dynamic>) {
        throw FormatException('Entrada inválida: ${item.key}');
      }
      result[item.key] = ProgressEntry.fromJson(
        item.value as Map<String, dynamic>,
      );
    }
    return result;
  }
}
