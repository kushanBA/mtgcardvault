import 'package:flutter/material.dart';
import '../../../features/binders/domain/entities/binder.dart' as binders;
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

class GamesQuizStep extends StatelessWidget {
  final Set<binders.Game> selected;
  final ValueChanged<binders.Game> onToggle;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GamesQuizStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onContinue,
  });

  static const _options = [
    binders.Game.mtg,
    binders.Game.pokemon,
    binders.Game.yugioh,
    binders.Game.lorcana,
    binders.Game.onePiece,
  ];

  static const _liveNow = {binders.Game.mtg};

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(step: 2, totalSteps: 6, onBack: onBack),
            const SizedBox(height: 26),
            Text('What do you collect?', style: theme.fontDisplay(fontSize: 25, color: t.ink)),
            const SizedBox(height: 10),
            Text(
              "Pick all that apply. We'll tune prices and alerts to your games.",
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final game = _options[i];
                  final on = selected.contains(game);
                  final live = _liveNow.contains(game);
                  final subtitle = live
                      ? 'Live prices'
                      : on
                      ? "Coming soon · you'll get early access"
                      : 'Coming soon';
                  return GestureDetector(
                    onTap: () => onToggle(game),
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
                            child: Text(
                              game.label.substring(0, 1),
                              style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.label,
                                  style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(subtitle, style: TextStyle(color: live ? t.up : t.muted, fontSize: 11.5)),
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
