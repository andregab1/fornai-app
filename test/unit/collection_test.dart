import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornai_app/features/backup/backup_codec.dart';
import 'package:fornai_app/features/catalog/domain/models.dart';
import 'package:fornai_app/features/collection/data/progress_repository.dart';
import 'package:fornai_app/features/collection/domain/collection_controller.dart';
import '../test_catalog.dart';

void main() {
  test('calcula progresso, busca sem acentos e filtros', () async {
    final repository = MemoryProgressRepository();
    final container = ProviderContainer(
      overrides: [
        catalogProvider.overrideWithValue(testCatalog()),
        progressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(collectionProvider.notifier);
    await controller.toggle('water.normal', true);
    expect(container.read(collectionProvider).collectedCount, 1);
    expect(container.read(collectionProvider).completion, closeTo(1 / 3, .001));
    controller.setQuery('agua');
    expect(
      container.read(collectionProvider).visibleElementals.single.id,
      'water',
    );
    controller.setQuery('');
    controller.setFilter(CollectionFilter.incomplete);
    expect(
      container.read(collectionProvider).visibleElementals.single.id,
      'water',
    );
    controller.setFilter(CollectionFilter.comingSoon);
    expect(
      container.read(collectionProvider).visibleElementals.single.id,
      'future',
    );
  });

  test(
    'atualização do catálogo preserva progresso desconhecido no armazenamento',
    () async {
      final repository = MemoryProgressRepository();
      await repository.write(
        'legacy.variant',
        ProgressEntry(collected: true, collectedAt: DateTime.utc(2026)),
      );
      final container = ProviderContainer(
        overrides: [
          catalogProvider.overrideWithValue(testCatalog()),
          progressRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      expect(
        container
            .read(collectionProvider)
            .progress['legacy.variant']
            ?.collected,
        isTrue,
      );
      await container
          .read(collectionProvider.notifier)
          .toggle('water.normal', true);
      expect(repository.values['legacy.variant']?.collected, isTrue);
    },
  );

  test('backup faz round-trip e rejeita formato inválido', () {
    const codec = BackupCodec();
    final source = codec.encode(
      catalogVersion: 'test.1',
      entries: {'water.normal': ProgressEntry(collected: true)},
      exportedAt: DateTime.utc(2026),
    );
    final decoded = codec.decode(source, knownVariantIds: {'water.normal'});
    expect(decoded['water.normal']?.collected, isTrue);
    expect(
      () => codec.decode(
        '{"format":"errado"}',
        knownVariantIds: {'water.normal'},
      ),
      throwsFormatException,
    );
  });
}
