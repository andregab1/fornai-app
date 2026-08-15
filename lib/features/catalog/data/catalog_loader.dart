import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models.dart';

class CatalogLoader {
  const CatalogLoader();
  Future<Catalog> load() async {
    final source = await rootBundle.loadString('assets/data/catalog.json');
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Catálogo inválido.');
    }
    return Catalog.fromJson(decoded);
  }
}
