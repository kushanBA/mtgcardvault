import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../core/pricing/price_category.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool resetDone = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final selectedPriceCat = ref.watch(priceCategoryProvider);
    final t = theme.light;
    final sold = store.listings
        .where((l) => l.status == ListingStatus.sold)
        .length;
    final publicBinders = store.binders.where((b) => b.isPublic).length;

    Widget row(
      String label,
      String value, {
      Color? color,
      VoidCallback? onTap,
      bool last = false,
    }) {
      final child = Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: color ?? t.ink, fontSize: 13.5),
            ),
            Text(value, style: TextStyle(color: t.muted, fontSize: 12.5)),
          ],
        ),
      );
      return onTap != null
          ? GestureDetector(onTap: onTap, child: child)
          : child;
    }

    return Container(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            'Profile',
            style: TextStyle(
              color: t.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: t.accentBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CP',
                        style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Collector since 2026',
                            style: TextStyle(color: t.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ui.Chip(
                      label: '✓ Verified seller',
                      bg: t.accentBg,
                      color: t.accent,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    children: [
                      _ProfileStat(value: '★ 5.0', label: 'rating', t: t),
                      const SizedBox(width: 8),
                      _ProfileStat(value: '$sold', label: 'sales', t: t),
                      const SizedBox(width: 8),
                      _ProfileStat(
                        value: '$publicBinders',
                        label: 'public binders',
                        t: t,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              'Achievements',
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: Image.asset(
                        'assets/illustrations/badges.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'First scan · first sale · hot rip · full binder · fair trade · top collector — unlock as you go.',
                    style: TextStyle(color: t.muted, fontSize: 11.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              'Settings',
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                row('Currency', 'USD \$', onTap: () {}),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price',
                        style: TextStyle(color: t.ink, fontSize: 13.5),
                      ),
                      DropdownButton<PriceCategory>(
                        value: selectedPriceCat,
                        underline: const SizedBox(),
                        style: TextStyle(color: t.muted, fontSize: 12.5),
                        items: PriceCategory.values.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c.label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(priceCategoryProvider.notifier).select(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                row('Offline price cache', 'cached today · on'),
                row('Price alerts', 'signals + deal radar'),
                row('Data', 'export CSV · coming soon'),
                Builder(
                  builder: (_) {
                    return GestureDetector(
                      onTap: () {
                        store.resetAll();
                        setState(() => resetDone = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reset demo data',
                              style: TextStyle(color: t.down, fontSize: 13.5),
                            ),
                            Text(
                              resetDone ? 'reset ✓' : 'binders, listings, pool',
                              style: TextStyle(color: t.muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => ref.read(authNotifierProvider.notifier).logout(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: t.line)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log out',
                          style: TextStyle(color: t.down, fontSize: 13.5),
                        ),
                        Text(
                          '',
                          style: TextStyle(color: t.muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              'About this build',
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo build with simulated recognition and a mock live market (${store.cards.length} cards, ticking every 3s). '
                  'The real pricing and recognition algorithm plugs into lib/data/services.dart.',
                  style: TextStyle(color: t.ink2, fontSize: 12.5, height: 1.5),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Portfolio now: \$${fmt(store.portfolioValue())}',
                    style: TextStyle(color: t.muted, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final theme.AppColors t;
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: TextStyle(color: t.muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
