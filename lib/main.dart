import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'app/fornai_app.dart';
import 'features/catalog/data/catalog_loader.dart';
import 'features/collection/data/progress_repository.dart';
import 'features/collection/domain/collection_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>('fornai_progress_v1');
  final catalog = await const CatalogLoader().load();
  runApp(
    ProviderScope(
      overrides: [
        catalogProvider.overrideWithValue(catalog),
        progressRepositoryProvider.overrideWithValue(
          HiveProgressRepository(box),
        ),
      ],
      child: const FornaiApp(),
    ),
  );
}
