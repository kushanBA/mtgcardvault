import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/binders/domain/entities/binder.dart' as binders;
import '../../../theme.dart' as theme;
import '../login_screen.dart';
import '../register_screen.dart';
import 'alerts_primer_step.dart';
import 'camera_primer_step.dart';
import 'collection_size_quiz_step.dart';
import 'first_scan_step.dart';
import 'games_quiz_step.dart';
import 'goals_quiz_step.dart';
import 'out_of_scans_paywall_step.dart';
import 'paywall_step.dart';
import 'plan_summary_step.dart';
import 'real_prices_step.dart';
import 'save_vault_step.dart';
import 'scan_result_step.dart';
import 'welcome_step.dart';

/// Welcome → Real prices → Games → Goals → Collection size → Your plan →
/// Camera primer → First scan → Scan result → Save your vault (real sign-in)
/// → Alerts primer → Paywall (real billing) → Out-of-scans paywall.
///
/// Sign-in (Save your vault / email auth) and billing (both Paywall steps)
/// are wired to the real AuthBloc/BillingBloc — everything before that is
/// illustrative. Real sign-in succeeding auto-advances the flow via the
/// BlocListener below, since it's async and can fail.
class OnboardingFlow extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingFlow({super.key, required this.onDone});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _Step {
  welcome,
  realPrices,
  games,
  goals,
  collectionSize,
  plan,
  cameraPrimer,
  firstScan,
  scanResult,
  saveVault,
  emailAuth,
  alertsPrimer,
  paywall,
  outOfScansPaywall,
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step step = _Step.welcome;
  Set<binders.Game> selectedGames = {binders.Game.mtg, binders.Game.pokemon};
  Set<OnboardingGoal> selectedGoals = {OnboardingGoal.priceCards, OnboardingGoal.trackValue};
  CollectionSize collectionSize = CollectionSize.seriousCollection;
  bool _showRegisterInEmailAuth = true;

  void _goTo(_Step s) => setState(() => step = s);

  void _toggleGame(binders.Game g) {
    setState(() {
      if (!selectedGames.remove(g)) selectedGames.add(g);
    });
  }

  void _toggleGoal(OnboardingGoal g) {
    setState(() {
      if (!selectedGoals.remove(g)) selectedGoals.add(g);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != AuthStatus.authenticated &&
          current.status == AuthStatus.authenticated &&
          (step == _Step.saveVault || step == _Step.emailAuth),
      listener: (context, state) => _goTo(_Step.alertsPrimer),
      child: Container(color: theme.light.bg, child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case _Step.welcome:
        return WelcomeStep(onGetStarted: () => _goTo(_Step.realPrices), onSignIn: widget.onDone);
      case _Step.realPrices:
        return RealPricesStep(onBack: () => _goTo(_Step.welcome), onContinue: () => _goTo(_Step.games));
      case _Step.games:
        return GamesQuizStep(
          selected: selectedGames,
          onToggle: _toggleGame,
          onBack: () => _goTo(_Step.realPrices),
          onContinue: () => _goTo(_Step.goals),
        );
      case _Step.goals:
        return GoalsQuizStep(
          selected: selectedGoals,
          onToggle: _toggleGoal,
          onBack: () => _goTo(_Step.games),
          onContinue: () => _goTo(_Step.collectionSize),
        );
      case _Step.collectionSize:
        return CollectionSizeQuizStep(
          selected: collectionSize,
          onSelect: (s) => setState(() => collectionSize = s),
          onBack: () => _goTo(_Step.goals),
          onContinue: () => _goTo(_Step.plan),
        );
      case _Step.plan:
        return PlanSummaryStep(
          selectedGames: selectedGames,
          selectedGoals: selectedGoals,
          collectionSize: collectionSize,
          onBack: () => _goTo(_Step.collectionSize),
          onContinue: () => _goTo(_Step.cameraPrimer),
        );
      case _Step.cameraPrimer:
        return CameraPrimerStep(
          onBack: () => _goTo(_Step.plan),
          onContinue: () => _goTo(_Step.firstScan),
          onSkip: widget.onDone,
        );
      case _Step.firstScan:
        // Illustrative viewfinder — see FirstScanStep's doc comment. Any of
        // its controls "complete" the illustrative scan.
        return FirstScanStep(onClose: widget.onDone, onScan: () => _goTo(_Step.scanResult));
      case _Step.scanResult:
        return ScanResultStep(
          freeScansLeft: 9,
          onClose: widget.onDone,
          onAddToVault: () => _goTo(_Step.saveVault),
          onScanAnother: () => _goTo(_Step.firstScan),
        );
      case _Step.saveVault:
        // Real Google Sign-In (AuthBloc) and real email auth (routes to
        // emailAuth below). Apple stays disabled — not built yet. Advancing
        // on success is handled by the BlocListener in build(), not here,
        // since sign-in is async.
        return SaveVaultStep(
          onBack: () => _goTo(_Step.scanResult),
          onEmail: () {
            setState(() => _showRegisterInEmailAuth = true);
            _goTo(_Step.emailAuth);
          },
        );
      case _Step.emailAuth:
        return _showRegisterInEmailAuth
            ? RegisterScreen(onHaveAccount: () => setState(() => _showRegisterInEmailAuth = false))
            : LoginScreen(onCreateAccount: () => setState(() => _showRegisterInEmailAuth = true));
      case _Step.alertsPrimer:
        return AlertsPrimerStep(
          onSkip: () => _goTo(_Step.paywall),
          onTurnOnAlerts: () => _goTo(_Step.paywall),
          onMaybeLater: () => _goTo(_Step.paywall),
        );
      case _Step.paywall:
        // Real BillingBloc — see PaywallStep's doc comment. A real purchase
        // finishes onboarding directly; declining shows one more offer
        // before finishing (outOfScansPaywall) — the two must never share
        // a callback, or a successful purchase would look like a decline.
        return PaywallStep(
          onPurchased: widget.onDone,
          onDeclined: () => _goTo(_Step.outOfScansPaywall),
        );
      case _Step.outOfScansPaywall:
        // Also real BillingBloc. Reachable here for review; its natural
        // real home is the actual scan-limit moment in `scan_screen.dart`,
        // not the first-run tour.
        return OutOfScansPaywallStep(onDone: widget.onDone, onSeeAllPlans: () => _goTo(_Step.paywall));
    }
  }
}
