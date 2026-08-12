import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';
import 'core/storage/local_storage.dart';
import 'data/store.dart';
import 'data/types.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/state/auth_state.dart';
import 'nav.dart';
import 'presentation/screens/binder_detail_screen.dart';
import 'presentation/screens/binders_screen.dart';
import 'presentation/screens/card_detail_screen.dart';
import 'presentation/screens/compare_screen.dart';
import 'presentation/screens/deal_radar_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/quick_sell_sheet.dart';
import 'presentation/screens/rip_mode_screen.dart';
import 'presentation/screens/scan_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/sell_screen.dart';
import 'presentation/screens/show_mode_screen.dart';
import 'presentation/screens/signals_screen.dart';
import 'theme.dart' as theme;

void main() {
  runApp(const ProviderScope(child: CardVaultApp()));
}

class CardVaultApp extends StatefulWidget {
  const CardVaultApp({super.key});

  @override
  State<CardVaultApp> createState() => _CardVaultAppState();
}

class _CardVaultAppState extends State<CardVaultApp> {
  // null = still reading storage; onboarding shows only on first-ever launch
  bool? onboarded;

  @override
  void initState() {
    super.initState();
    load<bool>(
      'onboarded',
      (j) => j as bool,
    ).then((v) => setState(() => onboarded = v ?? false));
  }

  void _finishOnboarding() {
    setState(() => onboarded = true);
    save('onboarded', true);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (onboarded == null) {
      child = Container(color: theme.light.bg);
    } else if (!onboarded!) {
      child = OnboardingScreen(onDone: _finishOnboarding);
    } else {
      child = const _AuthGate();
    }

    return MaterialApp(
      title: 'CardVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: theme.light.bg),
      home: SafeArea(child: Scaffold(body: child)),
    );
  }
}

/// Watches auth state and shows the splash / auth flow / tab shell accordingly.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    switch (state.status) {
      case AuthStatus.initial:
      case AuthStatus.restoring:
        return Container(color: theme.light.bg);
      case AuthStatus.authenticated:
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Store()),
            ChangeNotifierProvider(create: (_) => Nav()),
          ],
          child: const _Shell(),
        );
      case AuthStatus.loading:
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const _AuthFlow();
    }
  }
}

class _AuthFlow extends StatefulWidget {
  const _AuthFlow();

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    return _showRegister
        ? RegisterPage(
            onHaveAccount: () => setState(() => _showRegister = false),
          )
        : LoginPage(
            onCreateAccount: () => setState(() => _showRegister = true),
          );
  }
}

const _tabs = [
  (AppTab.home, 'Home', '⌂'),
  (AppTab.binders, 'Binders', '▦'),
  (AppTab.scan, 'Scan', '◉'),
  // (AppTab.sell, 'Sell', '⇄'),
  (AppTab.profile, 'Profile', '◇'),
];

class _Shell extends StatelessWidget {
  const _Shell();

  Widget _tabBody(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const HomeScreen();
      case AppTab.scan:
        return const ScanScreen();
      case AppTab.binders:
        return const BindersScreen();
      // case AppTab.sell:
      //   return const SellScreen();
      case AppTab.profile:
        return const ProfileScreen();
    }
  }

  Widget _overlayScreen(NavOverlay o) {
    switch (o.type) {
      case NavOverlayType.card:
        return CardDetailScreen(
          cardId: o.cardId!,
          condition: o.condition ?? Condition.nm,
        );
      case NavOverlayType.binder:
        return BinderDetailScreen(binderId: o.binderId!);
      case NavOverlayType.sellSheet:
        return QuickSellSheet(cardId: o.cardId!, condition: o.condition!);
      case NavOverlayType.rip:
        return const RipModeScreen();
      case NavOverlayType.signals:
        return const SignalsScreen();
      case NavOverlayType.radar:
        return const DealRadarScreen();
      case NavOverlayType.compare:
        return CompareScreen(binderId: o.binderId!);
      case NavOverlayType.show:
        return ShowModeScreen(listingId: o.listingId!);
      case NavOverlayType.search:
        return const SearchScreen();
      case NavOverlayType.scanForBinder:
        return ScanScreen(targetBinderId: o.binderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Nav>();
    final dark = nav.tab == AppTab.binders || nav.tab == AppTab.scan;
    final t = dark ? theme.exchange : theme.light;

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _tabBody(nav.tab)),
                for (final o in nav.overlays)
                  Positioned.fill(child: _overlayScreen(o)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border(top: BorderSide(color: t.line)),
            ),
            child: Row(
              children: _tabs.map((tb) {
                final active = nav.tab == tb.$1;
                final color = active
                    ? (dark ? theme.exchange.accent : theme.light.accent)
                    : (dark ? theme.exchange.muted : theme.light.muted);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => nav.setTab(tb.$1),
                    child: Column(
                      children: [
                        Text(
                          tb.$3,
                          style: TextStyle(fontSize: 18, color: color),
                        ),
                        Text(
                          tb.$2,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
