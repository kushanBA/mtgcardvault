import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/bloc/resource.dart';
import '../../../core/error/failure.dart';
import '../../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../../features/billing/presentation/bloc/billing_event.dart';
import '../../../features/billing/presentation/bloc/billing_state.dart';
import '../../../features/billing/subscription_product_ids.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

/// The contextual paywall shown when someone actually exhausts their free
/// scans — distinct from [PaywallStep] (the general end-of-tour upsell,
/// see that file), which "See all plans" hands off to for the Monthly
/// option. Real store data and real purchase via [BillingBloc], same as
/// [PaywallStep].
class OutOfScansPaywallStep extends StatefulWidget {
  final VoidCallback onDone;
  final VoidCallback onSeeAllPlans;

  const OutOfScansPaywallStep({super.key, required this.onDone, required this.onSeeAllPlans});

  @override
  State<OutOfScansPaywallStep> createState() => _OutOfScansPaywallStepState();
}

class _OutOfScansPaywallStepState extends State<OutOfScansPaywallStep> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<BillingBloc>();
    if (bloc.state.plans is ResourceInitial) {
      bloc.add(const LoadPlans(subscriptionProductIds));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return BlocListener<BillingBloc, BillingState>(
      listenWhen: (previous, current) => previous.purchaseStatus != current.purchaseStatus,
      listener: (context, state) {
        switch (state.purchaseStatus) {
          case SubscriptionPurchaseStatus.success:
            widget.onDone();
          case SubscriptionPurchaseStatus.error:
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Purchase failed.')));
          case SubscriptionPurchaseStatus.idle:
          case SubscriptionPurchaseStatus.pending:
            break;
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: t.panel),
                      child: Text('✕', style: TextStyle(color: t.ink2, fontSize: 14)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const _CollectionFan(),
                      const SizedBox(height: 28),
                      Text(
                        'YOUR 10 SCANS ARE WORTH',
                        style: TextStyle(
                          color: t.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('\$1,284.60', style: theme.fontHeavy(fontSize: 40, color: t.accent)),
                      const SizedBox(height: 22),
                      Text(
                        "You've used all 10 free scans.",
                        textAlign: TextAlign.center,
                        style: theme.fontDisplay(fontSize: 22, color: t.ink),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Go Pro to price the rest of your collection and keep this value tracked.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.ink2, fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) => state.plans.when(
                  initial: () => const SizedBox(
                    height: 70,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  loading: () => const SizedBox(
                    height: 70,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(
                    e is Failure ? e.error : e.toString(),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                  data: (plans) {
                    final yearly = firstWhereOrNull(plans, (p) => p.id == premiumYearlyProductId);
                    if (yearly == null) return const SizedBox.shrink();
                    return _PlanCard(plan: yearly, t: t);
                  },
                ),
              ),
              const SizedBox(height: 14),
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  final pending = state.purchaseStatus == SubscriptionPurchaseStatus.pending;
                  final yearly = firstWhereOrNull(
                    state.plans.valueOrNull ?? const <ProductDetails>[],
                    (p) => p.id == premiumYearlyProductId,
                  );
                  return GoldButton(
                    onTap: (pending || yearly == null)
                        ? null
                        : () => context.read<BillingBloc>().add(PurchaseRequested(yearly)),
                    label: pending ? 'Processing…' : 'Keep scanning with Pro',
                  );
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.onSeeAllPlans,
                child: Text(
                  'See all plans',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.ink2, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.read<BillingBloc>().add(const RestoreRequested()),
                child: Text(
                  'Cancel anytime · Restore purchases',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.muted, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final ProductDetails plan;
  final theme.AppColors t;
  const _PlanCard({required this.plan, required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.accentBg,
            border: Border.all(color: t.accent),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              RadioDot(on: true, t: t),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(plan.description, style: TextStyle(color: t.muted, fontSize: 11.5)),
                  ],
                ),
              ),
              Text(plan.price, style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
            child: const Text(
              'SAVE 58%',
              style: TextStyle(color: Color(0xFF0B0E11), fontSize: 9.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

/// Five-card fan representing "your whole collection," rather than the one
/// specific Sheoldred card used elsewhere in onboarding.
class _CollectionFan extends StatelessWidget {
  const _CollectionFan();

  static const _colors = [
    Color(0xFF1B3A52),
    Color(0xFF4A1F24),
    Color(0xFF3B2A6B),
    Color(0xFF1F3B2E),
    Color(0xFF4A4319),
  ];

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    Widget card(int i) {
      final center = i == 2;
      final angle = (i - 2) * 0.16;
      final dx = (i - 2) * 34.0;
      return Transform.translate(
        offset: Offset(dx, center ? -14 : 0),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 92,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_colors[i], Colors.black.withValues(alpha: 0.35)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: center ? t.accent : Colors.black.withValues(alpha: 0.3),
                width: center ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [for (var i = 0; i < 5; i++) card(i)],
      ),
    );
  }
}
