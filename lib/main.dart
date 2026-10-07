import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/di/injector.dart';
import 'core/pricing/bloc/price_category_bloc.dart';
import 'core/pricing/bloc/price_category_event.dart';
import 'core/storage/local_storage.dart';
import 'data/store.dart';
import 'data/types.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/binders/presentation/bloc/binder_bloc.dart';
import 'features/collection/presentation/bloc/collection_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'nav.dart';
import 'presentation/screens/binder_detail_screen.dart';
import 'presentation/screens/binders_screen.dart';
import 'presentation/screens/card_detail_screen.dart';
import 'presentation/screens/compare_screen.dart';
import 'presentation/screens/deal_radar_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/onboarding/onboarding_flow.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/quick_sell_sheet.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/rip_mode_screen.dart';
import 'presentation/screens/scan_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/show_mode_screen.dart';
import 'presentation/screens/signals_screen.dart';
import 'presentation/screens/subscription_screen.dart';
import 'theme.dart' as theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  await SentryFlutter.init((options) {
    options.dsn =
        'https://034236508d627372689273b2091c2a7d@o4512066297856000.ingest.de.sentry.io/4512066423029840';
    options.tracesSampleRate = 0.01;
  });
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AuthRestoreRequested())),
        BlocProvider(create: (_) => sl<PriceCategoryBloc>()..add(const RestorePriceCategory())),
        BlocProvider(create: (_) => sl<BinderBloc>()),
        BlocProvider(create: (_) => sl<CollectionBloc>()),
        // Profile and Billing are root-scoped (not just post-login) because
        // onboarding's Save-your-vault/Paywall steps need them the moment
        // sign-in succeeds, before _AuthGate would otherwise provide them.
        BlocProvider(create: (_) => sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<BillingBloc>()),
      ],
      child: const CardVaultApp(),
    ),
  );
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
      child = OnboardingFlow(onDone: _finishOnboarding);
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
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
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
        ? RegisterScreen(
            onHaveAccount: () => setState(() => _showRegister = false),
          )
        : LoginScreen(
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

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  DateTime? _lastBackPress;

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
      case NavOverlayType.subscription:
        return const SubscriptionScreen();
    }
  }

  void _handlePop(bool didPop) {
    if (didPop) return;
    final nav = context.read<Nav>();
    if (nav.overlays.isNotEmpty) {
      nav.pop();
      return;
    } else if (nav.overlays.isEmpty && nav.tab != AppTab.home) {
      nav.setTab(AppTab.home);
      return;
    }
    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Nav>();
    final dark = nav.tab == AppTab.binders || nav.tab == AppTab.scan;
    final t = dark ? theme.exchange : theme.light;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePop(didPop),
      child: Container(
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
      ),
    );
  }
}
