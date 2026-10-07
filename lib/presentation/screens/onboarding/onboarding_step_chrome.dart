import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;

/// Small null-safe "first matching element" helper — avoids pulling in
/// package:collection (only a transitive dependency here) for one use.
T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

/// Back button + progress bar + "x/y" count, shared by every onboarding step
/// after Welcome.
class StepHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  const StepHeader({super.key, required this.step, required this.totalSteps, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.line)),
            child: Text('‹', style: TextStyle(color: t.ink2, fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: step / totalSteps,
              minHeight: 4,
              backgroundColor: t.line,
              valueColor: AlwaysStoppedAnimation(t.accent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('$step/$totalSteps', style: TextStyle(color: t.muted, fontSize: 12.5)),
      ],
    );
  }
}

/// The white "Continue" button shared by every step after Welcome (which
/// uses its own gold CTA instead).
class ContinueButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const ContinueButton({super.key, required this.onTap, this.label = 'Continue'});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: t.bg, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// The gold, higher-emphasis CTA used on Welcome and the plan-summary step.
/// A null [onTap] renders it disabled (dimmed, unresponsive).
class GoldButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const GoldButton({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? t.accent : t.accent.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF0B0E11).withValues(alpha: enabled ? 1 : 0.6),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Square, multi-select indicator — [GamesQuizStep] and [GoalsQuizStep] rows.
class Check extends StatelessWidget {
  final bool on;
  final theme.AppColors t;
  const Check({super.key, required this.on, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? t.accent : Colors.transparent,
        border: Border.all(color: on ? t.accent : t.line, width: 1.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: on ? Text('✓', style: TextStyle(color: t.bg, fontSize: 13, fontWeight: FontWeight.w900)) : null,
    );
  }
}

/// Round, single-select indicator — [CollectionSizeQuizStep] rows.
class RadioDot extends StatelessWidget {
  final bool on;
  final theme.AppColors t;
  const RadioDot({super.key, required this.on, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: on ? t.accent : t.line, width: 1.6),
      ),
      child: on
          ? Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
