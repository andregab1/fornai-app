import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../catalog/domain/models.dart';
import '../domain/collection_controller.dart';
import 'heart_checklist.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionProvider);
    final actions = ref.read(collectionProvider.notifier);
    ref.listen(collectionProvider.select((value) => value.errorMessage), (
      _,
      message,
    ) {
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'FORNAI',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            tooltip: 'Backup e restauração',
            onPressed: () => _backupSheet(context, actions),
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          IconButton(
            tooltip: 'Redefinir coleção',
            onPressed: () => _reset(context, actions),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(child: ProgressHeader(state: state)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: SearchFilters(state: state, actions: actions),
              ),
            ),
            if (state.visibleElementals.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 440,
                    mainAxisExtent: 330,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ElementalCard(
                      elemental: state.visibleElementals[index],
                      state: state,
                      actions: actions,
                    ),
                    childCount: state.visibleElementals.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.state});
  final CollectionState state;
  @override
  Widget build(BuildContext context) {
    final percent = (state.completion * 100).round();
    return Semantics(
      label:
          'Progresso geral: ${state.collectedCount} de ${state.totalCount} variantes, $percent por cento',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF244057)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUA COLEÇÃO',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${state.collectedCount} de ${state.totalCount} variantes',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.completion,
                minHeight: 10,
                backgroundColor: const Color(0xFF25384A),
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Catálogo ${state.catalog.catalogVersion} • salvo neste aparelho',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilters extends StatelessWidget {
  const SearchFilters({super.key, required this.state, required this.actions});
  final CollectionState state;
  final CollectionController actions;
  static const labels = {
    CollectionFilter.all: 'Todos',
    CollectionFilter.complete: 'Completos',
    CollectionFilter.incomplete: 'Incompletos',
    CollectionFilter.notStarted: 'Não iniciados',
    CollectionFilter.available: 'Disponíveis',
    CollectionFilter.comingSoon: 'Em breve',
  };
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        onChanged: actions.setQuery,
        decoration: const InputDecoration(
          labelText: 'Buscar Elemental',
          hintText: 'Ex.: Água, Batman...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in CollectionFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(labels[filter]!),
                  selected: state.filter == filter,
                  onSelected: (_) => actions.setFilter(filter),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class ElementalCard extends StatelessWidget {
  const ElementalCard({
    super.key,
    required this.elemental,
    required this.state,
    required this.actions,
  });
  final Elemental elemental;
  final CollectionState state;
  final CollectionController actions;
  @override
  Widget build(BuildContext context) {
    final count = state.collectedFor(elemental);
    final soon = elemental.availability == Availability.comingSoon;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDetails(context, elemental, state),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElementalPlaceholder(
                    id: elemental.id,
                    imageAsset: elemental.variants.first.imageAsset,
                    size: 58,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          elemental.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '$count de ${elemental.variants.length} coletadas',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message:
                        elemental.validationStatus == ValidationStatus.confirmed
                        ? 'Confirmado'
                        : 'Validação pendente',
                    child: Icon(
                      elemental.validationStatus == ValidationStatus.confirmed
                          ? Icons.verified_outlined
                          : Icons.warning_amber_rounded,
                      color:
                          elemental.validationStatus ==
                              ValidationStatus.confirmed
                          ? AppColors.cyan
                          : AppColors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (soon)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 40, color: AppColors.amber),
                        SizedBox(height: 8),
                        Text(
                          'EM BREVE',
                          style: TextStyle(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Disponibilidade não confirmada.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: elemental.variants.length,
                    itemBuilder: (context, index) {
                      final variant = elemental.variants[index];
                      final checked =
                          state.progress[variant.id]?.collected ?? false;
                      return SizedBox(
                        height: 52,
                        child: InkWell(
                          onTap: () => actions.toggle(variant.id, !checked),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              HeartChecklist(
                                value: checked,
                                semanticLabel:
                                    '${variant.name} de ${elemental.name}',
                                onChanged: (value) =>
                                    actions.toggle(variant.id, value),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(variant.name),
                                    if (variant.validationStatus ==
                                        ValidationStatus.unconfirmed)
                                      const Text(
                                        'Confirmação pendente',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.amber,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: soon
                          ? null
                          : () => actions.setElemental(elemental, true),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Marcar todas'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Desmarcar todas',
                    onPressed: soon
                        ? null
                        : () => actions.setElemental(elemental, false),
                    icon: const Icon(Icons.remove_done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElementalPlaceholder extends StatelessWidget {
  const ElementalPlaceholder({
    super.key,
    required this.id,
    required this.imageAsset,
    required this.size,
  });
  final String id;
  final String imageAsset;
  final double size;
  @override
  Widget build(BuildContext context) {
    final hue = id.codeUnits.fold<int>(0, (sum, item) => sum + item) % 360;
    final color = HSVColor.fromAHSV(1, hue.toDouble(), .48, .78).toColor();
    return Semantics(
      label: 'Imagem provisória',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.asset(
            imageAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.auto_awesome, color: color, size: size * .48),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'Nenhum Elemental encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text('Ajuste a busca ou escolha outro filtro.'),
        ],
      ),
    ),
  );
}

Future<void> showDetails(
  BuildContext context,
  Elemental elemental,
  CollectionState state,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElementalPlaceholder(
                  id: elemental.id,
                  imageAsset: elemental.variants.first.imageAsset,
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        elemental.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(elemental.season),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Variantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Flexible(
              child: ListView(
                children: [
                  for (final variant in elemental.variants)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: HeartChecklist(
                        value: state.progress[variant.id]?.collected ?? false,
                        semanticLabel: '${variant.name} de ${elemental.name}',
                      ),
                      title: Text(variant.name),
                      subtitle: Text(
                        variant.validationStatus == ValidationStatus.confirmed
                            ? 'Confirmada'
                            : 'Validação pendente',
                      ),
                      trailing: variant.availability == Availability.comingSoon
                          ? const Text(
                              'Em breve',
                              style: TextStyle(color: AppColors.amber),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

Future<void> _reset(BuildContext context, CollectionController actions) async {
  final yes =
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Redefinir coleção?'),
          content: const Text(
            'Todos os checks deste aparelho serão removidos. Exporte um backup antes se quiser recuperá-los.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Redefinir'),
            ),
          ],
        ),
      ) ??
      false;
  if (yes) {
    await actions.reset();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Coleção redefinida.')));
    }
  }
}

Future<void> _backupSheet(BuildContext context, CollectionController actions) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Backup da coleção',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Contém somente checks e datas; nenhuma imagem.'),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: actions.exportBackup()),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup JSON copiado.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar backup JSON'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _importDialog(context, actions);
                },
                icon: const Icon(Icons.restore),
                label: const Text('Importar e mesclar backup'),
              ),
            ],
          ),
        ),
      ),
    );

Future<void> _importDialog(
  BuildContext context,
  CollectionController actions,
) async {
  final input = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Importar backup'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: input,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(
            labelText: 'JSON do backup',
            alignLabelWithHint: true,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              final count = await actions.importBackup(input.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count entradas importadas e mescladas.'),
                  ),
                );
              }
            } on FormatException catch (error) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            } catch (_) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Backup inválido ou corrompido.'),
                  ),
                );
              }
            }
          },
          child: const Text('Importar'),
        ),
      ],
    ),
  );
  input.dispose();
}
