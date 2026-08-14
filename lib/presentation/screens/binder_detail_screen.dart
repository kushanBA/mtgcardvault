import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../core/error/failure.dart';
import '../../core/pricing/price_category.dart';
import '../../features/binders/domain/entities/binder.dart' as api;
import '../../features/binders/presentation/providers/binder_providers.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class BinderDetailScreen extends ConsumerWidget {
  final String binderId;
  const BinderDetailScreen({super.key, required this.binderId});

  Future<void> _togglePublic(
    BuildContext context,
    WidgetRef ref,
    api.Binder b,
  ) async {
    final either = await ref.read(updateBinderUseCaseProvider)(
      b.id,
      isPublic: !b.isPublic,
    );
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) => ref.invalidate(binderDetailProvider(b.id)),
    );
  }

  Future<void> _renameBinder(
    BuildContext context,
    WidgetRef ref,
    theme.AppColors t,
    api.Binder b,
  ) async {
    final controller = TextEditingController(text: b.name);
    final newName = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Dialog(
        backgroundColor: t.panel,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rename binder',
                style: TextStyle(
                  color: t.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: t.ink, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Binder name',
                  hintStyle: TextStyle(color: t.muted),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(controller.text.trim()),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF0B0E11),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (newName == null || newName.isEmpty || newName == b.name) return;

    final either = await ref.read(updateBinderUseCaseProvider)(
      b.id,
      name: newName,
    );
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) => ref.invalidate(binderDetailProvider(b.id)),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    theme.AppColors t,
    String binderId,
    int position,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Dialog(
        backgroundColor: t.panel,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove this card from the binder?',
                style: TextStyle(
                  color: t.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: t.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: t.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    final either = await ref.read(removeCardFromPocketUseCaseProvider)(
      binderId,
      position,
    );
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) => ref.invalidate(binderDetailProvider(binderId)),
    );
  }

  Widget _pocketTile(
    BuildContext context,
    WidgetRef ref,
    theme.AppColors t,
    api.Binder b,
    api.Pocket p,
    PriceCategory priceCategory,
  ) {
    final width = MediaQuery.of(context).size.width * 0.28;

    if (p.isEmpty) {
      return GestureDetector(
        onTap: () => context.read<Nav>().push(NavOverlay.scanForBinder(b.id)),
        child: Container(
          width: width,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2B3139), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('+', style: TextStyle(color: t.muted, fontSize: 20)),
        ),
      );
    }

    final card = p.catalogCard;
    final price = card?.priceFor(priceCategory);
    final priceLabel = price != null ? '\$${price.toStringAsFixed(2)}' : null;
    return Container(
      width: width,
      padding: const EdgeInsets.all(7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: card != null
                    ? () => ui.showEnlargedImage(
                        context,
                        NetworkImage(card.imageUrl),
                        priceLabel: priceLabel,
                      )
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: card != null
                      ? Image.network(
                          card.imageUrl,
                          width: 62,
                          height: 86,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stackTrace) =>
                              Container(width: 62, height: 86, color: t.line),
                        )
                      : Container(width: 62, height: 86, color: t.line),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  card?.name ?? 'Unknown card',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (priceLabel != null)
                Text(
                  priceLabel,
                  style: TextStyle(
                    color: t.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Positioned(
            top: -3,
            right: -3,
            child: GestureDetector(
              onTap: () => _confirmRemove(context, ref, t, b.id, p.position),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xCC131316),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '✕',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final binderAsync = ref.watch(binderDetailProvider(binderId));
    final priceCategory = ref.watch(priceCategoryProvider);

    return Container(
      color: t.bg,
      child: binderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: nav.pop,
                child: Text(
                  '‹ Back',
                  style: TextStyle(color: t.muted, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                e is Failure ? e.error : e.toString(),
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ),
        ),
        data: (b) {
          final filled = b.pockets.where((p) => !p.isEmpty).toList();
          final totalValue = filled.fold<double>(
            0,
            (sum, p) => sum + (p.catalogCard?.priceFor(priceCategory) ?? 0),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: nav.pop,
                    child: Text(
                      '‹ Back',
                      style: TextStyle(color: t.muted, fontSize: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _togglePublic(context, ref, b),
                    child: ui.Chip(
                      label: b.isPublic
                          ? 'PUBLIC · tap to unpublish'
                          : 'PRIVATE · tap to publish',
                      bg: b.isPublic ? const Color(0xFF1E2B26) : t.panel,
                      color: b.isPublic ? t.up : t.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _renameBinder(context, ref, t, b),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: b.name,
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  ✎',
                        style: TextStyle(color: t.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '${b.game.label} · ${filled.length}/9 pockets',
                style: TextStyle(color: t.muted, fontSize: 12.5),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Total value (${priceCategory.label}): \$${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (filled.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Opacity(
                          opacity: 0.95,
                          child: Image.asset(
                            'assets/illustrations/empty-binder.png',
                            width: 230,
                            height: 230,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        'This binder is empty — scan cards to fill its nine pockets.',
                        style: TextStyle(color: t.muted, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.pockets
                      .map(
                        (p) =>
                            _pocketTile(context, ref, t, b, p, priceCategory),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
