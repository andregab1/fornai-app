import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../backup/backup_codec.dart';
import '../../catalog/domain/models.dart';
import '../data/progress_repository.dart';

enum CollectionFilter {
  all,
  complete,
  incomplete,
  notStarted,
  available,
  comingSoon,
}

class CollectionState {
  const CollectionState({
    required this.catalog,
    required this.progress,
    this.query = '',
    this.filter = CollectionFilter.all,
    this.errorMessage,
  });
  final Catalog catalog;
  final Map<String, ProgressEntry> progress;
  final String query;
  final CollectionFilter filter;
  final String? errorMessage;

  int get collectedCount =>
      catalog.variantIds.where((id) => progress[id]?.collected ?? false).length;
  int get totalCount => catalog.variantIds.length;
  double get completion => totalCount == 0 ? 0 : collectedCount / totalCount;

  int collectedFor(Elemental elemental) => elemental.variants
      .where((variant) => progress[variant.id]?.collected ?? false)
      .length;

  List<Elemental> get visibleElementals {
    final normalized = _normalize(query);
    return catalog.elementals
        .where((elemental) {
          final count = collectedFor(elemental);
          final matchesSearch =
              normalized.isEmpty ||
              _normalize(elemental.name).contains(normalized);
          final matchesFilter = switch (filter) {
            CollectionFilter.all => true,
            CollectionFilter.complete => count == elemental.variants.length,
            CollectionFilter.incomplete =>
              count > 0 && count < elemental.variants.length,
            CollectionFilter.notStarted => count == 0,
            CollectionFilter.available =>
              elemental.availability == Availability.available,
            CollectionFilter.comingSoon =>
              elemental.availability == Availability.comingSoon,
          };
          return matchesSearch && matchesFilter;
        })
        .toList(growable: false);
  }

  CollectionState copyWith({
    Map<String, ProgressEntry>? progress,
    String? query,
    CollectionFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) => CollectionState(
    catalog: catalog,
    progress: progress ?? this.progress,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

String _normalize(String value) {
  const accented = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const plain = 'aaaaaeeeeiiiiooooouuuuc';
  var result = value.toLowerCase();
  for (var index = 0; index < accented.length; index++) {
    result = result.replaceAll(accented[index], plain[index]);
  }
  return result.trim();
}

final catalogProvider = Provider<Catalog>((ref) => throw UnimplementedError());
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => throw UnimplementedError(),
);
final collectionProvider =
    NotifierProvider<CollectionController, CollectionState>(
      CollectionController.new,
    );

class CollectionController extends Notifier<CollectionState> {
  late ProgressRepository _repository;
  final _backupCodec = const BackupCodec();

  @override
  CollectionState build() {
    _repository = ref.watch(progressRepositoryProvider);
    final catalog = ref.watch(catalogProvider);
    return CollectionState(catalog: catalog, progress: _repository.readAll());
  }

  void setQuery(String value) =>
      state = state.copyWith(query: value, clearError: true);
  void setFilter(CollectionFilter value) =>
      state = state.copyWith(filter: value, clearError: true);

  Future<void> toggle(String variantId, bool collected) async {
    final next = Map<String, ProgressEntry>.of(state.progress);
    final entry = ProgressEntry(
      collected: collected,
      collectedAt: collected ? DateTime.now() : null,
    );
    next[variantId] = entry;
    state = state.copyWith(progress: next, clearError: true);
    try {
      await _repository.write(variantId, entry);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Não foi possível salvar a alteração.',
      );
    }
  }

  Future<void> setElemental(Elemental elemental, bool collected) async {
    final next = Map<String, ProgressEntry>.of(state.progress);
    final timestamp = collected ? DateTime.now() : null;
    for (final variant in elemental.variants) {
      if (variant.availability == Availability.comingSoon) continue;
      next[variant.id] = ProgressEntry(
        collected: collected,
        collectedAt: timestamp,
      );
    }
    state = state.copyWith(progress: next, clearError: true);
    try {
      await _repository.writeAll(next);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Não foi possível salvar as variantes.',
      );
    }
  }

  Future<void> reset() async {
    await _repository.clear();
    state = state.copyWith(progress: const {}, clearError: true);
  }

  String exportBackup() => _backupCodec.encode(
    catalogVersion: state.catalog.catalogVersion,
    entries: state.progress,
  );

  Future<int> importBackup(String source) async {
    final imported = _backupCodec.decode(
      source,
      knownVariantIds: state.catalog.variantIds,
    );
    final merged = Map<String, ProgressEntry>.of(state.progress)
      ..addAll(imported);
    await _repository.writeAll(merged);
    state = state.copyWith(progress: merged, clearError: true);
    return imported.length;
  }
}
