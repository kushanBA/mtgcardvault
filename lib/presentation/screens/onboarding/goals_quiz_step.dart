import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

enum OnboardingGoal { priceCards, trackValue, sellTiming, findDeals, openPacks }

extension OnboardingGoalCopy on OnboardingGoal {
  String get title => switch (this) {
    OnboardingGoal.priceCards => 'Price my cards',
    OnboardingGoal.trackValue => "Track my collection's value",
    OnboardingGoal.sellTiming => 'Sell at the right time',
    OnboardingGoal.findDeals => 'Find deals below market',
    OnboardingGoal.openPacks => 'Open packs, track pulls',
  };

  String get subtitle => switch (this) {
    OnboardingGoal.priceCards => 'Instant value on every scan',
    OnboardingGoal.trackValue => 'Portfolio value and daily movers',
    OnboardingGoal.sellTiming => 'SELL and WATCH signals',
    OnboardingGoal.findDeals => 'Deal Radar alerts',
    OnboardingGoal.openPacks => 'Rip Mode tallies every pack',
  };

  String get icon => switch (this) {
    OnboardingGoal.priceCards => '🏷️',
    OnboardingGoal.trackValue => '📈',
    OnboardingGoal.sellTiming => '🔔',
    OnboardingGoal.findDeals => '🎯',
    OnboardingGoal.openPacks => '⚡',
  };

  /// Two-or-three-word form for the summary chip on the plan step.
  String get shortLabel => switch (this) {
    OnboardingGoal.priceCards => 'Price cards',
    OnboardingGoal.trackValue => 'Track value',
    OnboardingGoal.sellTiming => 'Sell smart',
    OnboardingGoal.findDeals => 'Find deals',
    OnboardingGoal.openPacks => 'Track pulls',
  };
}

class GoalsQuizStep extends StatelessWidget {
  final Set<OnboardingGoal> selected;
  final ValueChanged<OnboardingGoal> onToggle;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GoalsQuizStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(step: 3, totalSteps: 6, onBack: onBack),
            const SizedBox(height: 26),
            Text('What brings you to CardVault?', style: theme.fontDisplay(fontSize: 25, color: t.ink)),
            const SizedBox(height: 10),
            Text(
              "Choose your top goals — we'll shape your home screen around them.",
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: OnboardingGoal.values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final goal = OnboardingGoal.values[i];
                  final on = selected.contains(goal);
                  return GestureDetector(
                    onTap: () => onToggle(goal),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: on ? t.accentBg : t.panel,
                        border: Border.all(color: on ? t.accent : t.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(9)),
                            child: Text(goal.icon, style: const TextStyle(fontSize: 15)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(goal.subtitle, style: TextStyle(color: t.muted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          Check(on: on, t: t),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ContinueButton(onTap: onContinue),
          ],
        ),
      ),
    );
  }
}
