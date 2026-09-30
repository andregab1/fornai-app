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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1180
                ? 4
                : constraints.maxWidth >= 760
                ? 3
                : 2;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 76,
                  backgroundColor: AppColors.background.withValues(alpha: .96),
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 20,
                  title: const _BrandLockup(),
                  actions: [
                    IconButton(
                      tooltip: 'Backup e restaura\u00e7\u00e3o',
                      onPressed: () => _backupSheet(context, actions),
                      icon: const Icon(Icons.cloud_upload_outlined),
                    ),
                    IconButton(
                      tooltip: 'Redefinir cole\u00e7\u00e3o',
                      onPressed: () => _reset(context, actions),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                SliverToBoxAdapter(child: _HeroOverview(state: state)),
                SliverToBoxAdapter(
                  child: _CollectionToolbar(state: state, actions: actions),
                ),
                if (state.visibleElementals.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 364,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ElementalCard(
                          elemental: state.visibleElementals[index],
                          state: state,
                          actions: actions,
                        ),
                        childCount: state.visibleElementals.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cyan, AppColors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x3345D6D0), blurRadius: 18),
          ],
        ),
        child: const Icon(Icons.favorite_rounded, color: AppColors.background),
      ),
      const SizedBox(width: 12),
      const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FORNAI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          Text(
            'ELEMENTAL LOG',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    ],
  );
}

class _HeroOverview extends StatelessWidget {
  const _HeroOverview({required this.state});
  final CollectionState state;
  @override
  Widget build(BuildContext context) {
    final percent = (state.completion * 100).round();
    final remaining = state.totalCount - state.collectedCount;
    final seasonName = state.season == CollectionSeason.current
        ? 'Temporada atual'
        : 'Cole\u00e7\u00e3o antiga';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 248),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF152C42), Color(0xFF0C1828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x3345D6D0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -44,
              top: -58,
              child: _GlowOrb(
                color: AppColors.cyan.withValues(alpha: .14),
                size: 190,
              ),
            ),
            Positioned(
              right: 96,
              bottom: -94,
              child: _GlowOrb(
                color: AppColors.amber.withValues(alpha: .12),
                size: 170,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Eyebrow(
                              text:
                                  '$seasonName  /  ${state.catalog.catalogVersion}',
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sua cole\u00e7\u00e3o,\nem movimento.',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: .98,
                                    letterSpacing: -1.5,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Marque cada variante com um cora\u00e7\u00e3o e acompanhe o que falta.',
                              style: TextStyle(
                                color: AppColors.muted,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${state.collectedCount} de ${state.totalCount} variantes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ProgressOrb(
                        percent: percent,
                        progress: state.completion,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      _HeroStat(
                        value: '${state.collectedCount}',
                        label: 'coletadas',
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 10),
                      _HeroStat(
                        value: '$remaining',
                        label: 'pendentes',
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 10),
                      _HeroStat(
                        value: '${state.seasonElementals.length}',
                        label: 'elementais',
                        color: AppColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _ProgressOrb extends StatelessWidget {
  const _ProgressOrb({required this.percent, required this.progress});
  final int percent;
  final double progress;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 92,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 8,
          backgroundColor: const Color(0x3345D6D0),
          color: AppColors.cyan,
        ),
        Text(
          '$percent%',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x33102030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x223B566D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CollectionToolbar extends StatelessWidget {
  const _CollectionToolbar({required this.state, required this.actions});
  final CollectionState state;
  final CollectionController actions;
  @override
  Widget build(BuildContext context) {
    final filters = <CollectionFilter>[
      CollectionFilter.all,
      CollectionFilter.complete,
      CollectionFilter.incomplete,
      CollectionFilter.notStarted,
      CollectionFilter.available,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Eyebrow(text: 'CAT\u00c1LOGO'),
                    SizedBox(height: 4),
                    Text(
                      'Escolha sua pr\u00f3xima conquista',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _SeasonSwitcher(state: state, actions: actions),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: actions.setQuery,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar por nome...',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in filters) ...[
                  ChoiceChip(
                    label: Text(_filterLabel(filter)),
                    selected: state.filter == filter,
                    onSelected: (_) => actions.setFilter(filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(CollectionFilter filter) => switch (filter) {
    CollectionFilter.all => 'Todos',
    CollectionFilter.complete => 'Completos',
    CollectionFilter.incomplete => 'Em andamento',
    CollectionFilter.notStarted => 'N\u00e3o iniciados',
    CollectionFilter.available => 'Dispon\u00edveis',
    CollectionFilter.comingSoon => 'Dispon\u00edveis',
  };
}

class _SeasonSwitcher extends StatelessWidget {
  const _SeasonSwitcher({required this.state, required this.actions});
  final CollectionState state;
  final CollectionController actions;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => actions.setSeason(
      state.season == CollectionSeason.current
          ? CollectionSeason.legacy
          : CollectionSeason.current,
    ),
    icon: Icon(
      state.season == CollectionSeason.current
          ? Icons.history_rounded
          : Icons.arrow_back_rounded,
      size: 18,
    ),
    label: Text(
      state.season == CollectionSeason.current
          ? 'Cole\u00e7\u00e3o antiga'
          : 'Temporada atual',
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.cyan,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.6,
    ),
  );
}

class _ElementalCard extends StatelessWidget {
  const _ElementalCard({
    required this.elemental,
    required this.state,
    required this.actions,
  });
  final Elemental elemental;
  final CollectionState state;
  final CollectionController actions;
  @override
  Widget build(BuildContext context) {
    final collected = state.collectedFor(elemental);
    final total = elemental.variants.length;
    final complete = collected == total;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showElementalDetails(context, elemental, state, actions),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ElementalImage(asset: elemental.variants.first.imageAsset),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: .88),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            elemental.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _StatusPill(complete: complete),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$collected de $total variantes',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${(collected / total * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : collected / total,
                      minHeight: 7,
                      backgroundColor: const Color(0xFF22374A),
                      color: complete ? AppColors.amber : AppColors.cyan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final variant in elemental.variants.take(2))
                    _VariantPreview(
                      variant: variant,
                      checked: state.progress[variant.id]?.collected ?? false,
                      onChanged: (value) => actions.toggle(variant.id, value),
                    ),
                  if (elemental.variants.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4),
                      child: Text(
                        '+ ${elemental.variants.length - 2} outras variantes',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.complete});
  final bool complete;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: (complete ? AppColors.amber : AppColors.cyan).withValues(
        alpha: .16,
      ),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Icon(
      complete ? Icons.check_rounded : Icons.auto_awesome_rounded,
      color: complete ? AppColors.amber : AppColors.cyan,
      size: 15,
    ),
  );
}

class _VariantPreview extends StatelessWidget {
  const _VariantPreview({
    required this.variant,
    required this.checked,
    required this.onChanged,
  });
  final ElementalVariant variant;
  final bool checked;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!checked),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          HeartChecklist(
            value: checked,
            semanticLabel:
                '${variant.name}: ${checked ? "marcada" : "n\u00e3o marcada"}',
            onChanged: onChanged,
            color: const Color(0xFFFF5B89),
          ),
          Expanded(
            child: Text(
              variant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: checked ? AppColors.text : AppColors.muted,
                fontWeight: FontWeight.w700,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Icon(
            checked ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: checked ? AppColors.cyan : AppColors.muted,
            size: 17,
          ),
        ],
      ),
    ),
  );
}

class _ElementalImage extends StatelessWidget {
  const _ElementalImage({required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => Container(
      color: const Color(0xFF1A3044),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: AppColors.cyan,
          size: 34,
        ),
      ),
    ),
  );
}

Future<void> _showElementalDetails(
  BuildContext context,
  Elemental elemental,
  CollectionState state,
  CollectionController actions,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  builder: (context) =>
      _ElementalSheet(elemental: elemental, state: state, actions: actions),
);

class _ElementalSheet extends StatelessWidget {
  const _ElementalSheet({
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
    final complete = count == elemental.variants.length;
    return Container(
      constraints: const BoxConstraints(maxHeight: 720),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: _ElementalImage(
                      asset: elemental.variants.first.imageAsset,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        elemental.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count de ${elemental.variants.length} variantes marcadas',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  complete
                      ? Icons.verified_rounded
                      : Icons.auto_awesome_rounded,
                  color: complete ? AppColors.amber : AppColors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: complete
                        ? null
                        : () => actions.setElemental(elemental, true),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Marcar todas'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton.icon(
                    onPressed: count == 0
                        ? null
                        : () => actions.setElemental(elemental, false),
                    icon: const Icon(Icons.remove_done_rounded, size: 18),
                    label: const Text('Limpar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Eyebrow(text: 'VARIANTES'),
            const SizedBox(height: 8),
            for (final variant in elemental.variants)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    HeartChecklist(
                      value: state.progress[variant.id]?.collected ?? false,
                      semanticLabel: variant.name,
                      onChanged: (value) => actions.toggle(variant.id, value),
                      color: const Color(0xFFFF5B89),
                    ),
                    Expanded(
                      child: Text(
                        variant.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        variant.type.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.cyan, size: 44),
          const SizedBox(height: 16),
          const Text(
            'Nada encontrado',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente outro nome ou remova alguns filtros.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

Future<void> _reset(BuildContext context, CollectionController actions) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recome\u00e7ar a cole\u00e7\u00e3o?'),
          content: const Text(
            'Todos os cora\u00e7\u00f5es marcados neste aparelho ser\u00e3o removidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Recome\u00e7ar'),
            ),
          ],
        ),
      ) ??
      false;
  if (confirmed) {
    await actions.reset();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cole\u00e7\u00e3o reiniciada.')),
      );
    }
  }
}

Future<void> _backupSheet(BuildContext context, CollectionController actions) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Backup da cole\u00e7\u00e3o',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Exporte seus cora\u00e7\u00f5es ou importe um backup anterior.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: actions.exportBackup()),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup copiado.')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar backup JSON'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _importDialog(context, actions);
              },
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Importar e mesclar backup'),
            ),
          ],
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
                  SnackBar(content: Text('$count entradas mescladas.')),
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
                    content: Text('Backup inv\u00e1lido ou corrompido.'),
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
