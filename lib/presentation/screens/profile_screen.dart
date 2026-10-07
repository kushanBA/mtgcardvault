import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/store.dart';
import '../../core/bloc/resource.dart';
import '../../core/error/failure.dart';
import '../../core/pricing/bloc/price_category_bloc.dart';
import '../../core/pricing/bloc/price_category_event.dart';
import '../../core/pricing/price_category.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool resetDone = false;
  bool alertsSaving = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    if (bloc.state.profile is ResourceInitial) {
      bloc.add(const LoadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final selectedPriceCat = context.watch<PriceCategoryBloc>().state.category;
    final profileAsync = context.watch<ProfileBloc>().state.profile;
    final isPremium = profileAsync.valueOrNull?.isPremium ?? false;
    final t = theme.light;
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
            child: profileAsync.when(
              initial: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (e, _) => Text(
                e is Failure ? e.error : e.toString(),
                style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              ),
              data: (profile) => Column(
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
                          _initials(profile.name),
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
                              profile.name,
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Collector since ${profile.createdAt.year}',
                              style: TextStyle(color: t.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      children: [
                        _ProfileStat(
                          value: '${profile.salesCount}',
                          label: 'sales',
                          t: t,
                        ),
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
                row(
                  'Premium',
                  isPremium ? 'active ✓' : 'unlock unlimited scans, Signals + Deal Radar',
                  color: isPremium ? t.up : t.accent,
                  onTap: isPremium ? null : () => nav.push(NavOverlay.subscription()),
                ),
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
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<PriceCategoryBloc>().add(SelectPriceCategory(val));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                row('Offline price cache', 'cached today · on'),
                profileAsync.maybeWhen(
                  data: (profile) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: t.line)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price alerts',
                          style: TextStyle(color: t.ink, fontSize: 13.5),
                        ),
                        Switch(
                          value: profile.priceAlertsEnabled,
                          activeThumbColor: t.accent,
                          onChanged: alertsSaving
                              ? null
                              : (val) async {
                                  setState(() => alertsSaving = true);
                                  final either = await context
                                      .read<ProfileBloc>()
                                      .updatePriceAlerts(val);
                                  if (!mounted) return;
                                  setState(() => alertsSaving = false);
                                  either.match(
                                    (failure) => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          SnackBar(
                                            content: Text(failure.error),
                                          ),
                                        ),
                                    (_) {},
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                  orElse: () => row('Price alerts', 'signals + deal radar'),
                ),
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
                  onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
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
          ElevatedButton(
            onPressed: () {
              throw StateError("this is a test exception");
            },
            child: Text('sentry'),
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
