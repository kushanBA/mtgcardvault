import 'package:flutter/material.dart';
import '../../../features/binders/domain/entities/binder.dart' as binders;
import '../../../theme.dart' as theme;
import 'collection_size_quiz_step.dart';
import 'goals_quiz_step.dart';
import 'onboarding_step_chrome.dart';

class PlanSummaryStep extends StatelessWidget {
  final Set<binders.Game> selectedGames;
  final Set<OnboardingGoal> selectedGoals;
  final CollectionSize collectionSize;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const PlanSummaryStep({
    super.key,
    required this.selectedGames,
    required this.selectedGoals,
    required this.collectionSize,
    required this.onBack,
    required this.onContinue,
  });

  static const _steps = [
    (
      'Scan in bursts of 20',
      'Snap a stack, then price every card at once.',
    ),
    (
      'Watch your portfolio',
      'Total value, daily movers and a split by game.',
    ),
    (
      'Sell at the right moment',
      'SELL and WATCH signals when your cards move.',
    ),
  ];

  binders.Game? get _primaryGame {
    if (selectedGames.contains(binders.Game.mtg)) return binders.Game.mtg;
    return selectedGames.isEmpty ? null : selectedGames.first;
  }

  String get _goalsChip {
    final labels = selectedGoals.map((g) => g.shortLabel).take(2).toList();
    return labels.isEmpty ? 'Your goals' : labels.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final game = _primaryGame;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(step: 5, totalSteps: 6, onBack: onBack),
            const SizedBox(height: 22),
            Text(
              'YOUR VAULT PLAN',
              style: TextStyle(color: t.accent, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'A plan for ${collectionSize.planHeadline}.',
              style: theme.fontDisplay(fontSize: 26, color: t.ink),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(label: game?.label ?? 'Any game', t: t),
                _SummaryChip(label: collectionSize.shortRange, t: t),
                _SummaryChip(label: _goalsChip, t: t),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < _steps.length; i++)
                      _PlanRow(
                        number: i + 1,
                        title: _steps[i].$1,
                        body: _steps[i].$2,
                        last: i == _steps.length - 1,
                        t: t,
                      ),
                  ],
                ),
              ),
            ),
            Text(
              'Your first 10 scans are on us',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.muted, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            GoldButton(onTap: onContinue, label: 'Scan my first card'),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final theme.AppColors t;
  const _SummaryChip({required this.label, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: t.ink2, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final bool last;
  final theme.AppColors t;

  const _PlanRow({
    required this.number,
    required this.title,
    required this.body,
    required this.last,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.panel, shape: BoxShape.circle, border: Border.all(color: t.line)),
                child: Text(
                  '$number',
                  style: TextStyle(color: t.accent, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              if (!last) Expanded(child: Container(width: 1, color: t.line)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(body, style: TextStyle(color: t.ink2, fontSize: 12.5, height: 1.45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
