import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

enum CollectionSize { startingOut, growingBinder, seriousCollection, fullVault }

extension CollectionSizeCopy on CollectionSize {
  String get title => switch (this) {
    CollectionSize.startingOut => 'Just getting started',
    CollectionSize.growingBinder => 'Growing binder',
    CollectionSize.seriousCollection => 'Serious collection',
    CollectionSize.fullVault => 'Full-blown vault',
  };

  String get range => switch (this) {
    CollectionSize.startingOut => 'Under 100 cards',
    CollectionSize.growingBinder => '100–1,000 cards',
    CollectionSize.seriousCollection => '1,000–5,000 cards',
    CollectionSize.fullVault => '5,000+ cards',
  };

  /// Abbreviated form for the summary chip on the plan step.
  String get shortRange => switch (this) {
    CollectionSize.startingOut => 'Under 100 cards',
    CollectionSize.growingBinder => '100–1K cards',
    CollectionSize.seriousCollection => '1K–5K cards',
    CollectionSize.fullVault => '5,000+ cards',
  };

  /// A representative card count for "A plan for {this}."
  String get planHeadline => switch (this) {
    CollectionSize.startingOut => 'your first 100 cards',
    CollectionSize.growingBinder => 'your 500 cards',
    CollectionSize.seriousCollection => 'your 2,500 cards',
    CollectionSize.fullVault => 'your 5,000+ cards',
  };
}

class CollectionSizeQuizStep extends StatelessWidget {
  final CollectionSize? selected;
  final ValueChanged<CollectionSize> onSelect;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const CollectionSizeQuizStep({
    super.key,
    required this.selected,
    required this.onSelect,
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
            StepHeader(step: 4, totalSteps: 6, onBack: onBack),
            const SizedBox(height: 26),
            Text('How big is your collection?', style: theme.fontDisplay(fontSize: 25, color: t.ink)),
            const SizedBox(height: 10),
            Text(
              'A rough guess is fine — it sizes your vault plan.',
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: CollectionSize.values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final size = CollectionSize.values[i];
                  final on = size == selected;
                  return GestureDetector(
                    onTap: () => onSelect(size),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: on ? t.accentBg : t.panel,
                        border: Border.all(color: on ? t.accent : t.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  size.title,
                                  style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(size.range, style: TextStyle(color: t.muted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          RadioDot(on: on, t: t),
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
