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

/// The general end-of-tour upsell — real store products, real purchase via
/// [BillingBloc]. See [OutOfScansPaywallStep] for the contextual variant
/// shown when someone actually exhausts their free scans.
class PaywallStep extends StatefulWidget {
  /// A real purchase completed — finish onboarding as a Premium account.
  final VoidCallback onPurchased;

  /// Closed or declined without buying — routed separately from
  /// [onPurchased] on purpose, since a successful purchase must never be
  /// treated the same as skipping it.
  final VoidCallback onDeclined;

  const PaywallStep({super.key, required this.onPurchased, required this.onDeclined});

  @override
  State<PaywallStep> createState() => _PaywallStepState();
}

class _PaywallStepState extends State<PaywallStep> {
  String? _selectedProductId;

  static const _features = [
    'Unlimited scans + Burst mode',
    'Live portfolio value & daily movers',
    'SELL / WATCH signals & Deal Radar',
    'Price alerts on every card you own',
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BillingBloc>();
    if (bloc.state.plans is ResourceInitial) {
      bloc.add(const LoadPlans(subscriptionProductIds));
    }
  }

  void _selectDefault(List<ProductDetails> plans) {
    if (_selectedProductId != null || plans.isEmpty) return;
    final yearly = firstWhereOrNull(plans, (p) => p.id == premiumYearlyProductId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedProductId != null) return;
      setState(() => _selectedProductId = (yearly ?? plans.first).id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return BlocListener<BillingBloc, BillingState>(
      listenWhen: (previous, current) => previous.purchaseStatus != current.purchaseStatus,
      listener: (context, state) {
        switch (state.purchaseStatus) {
          case SubscriptionPurchaseStatus.success:
            widget.onPurchased();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onDeclined,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: t.panel),
                      child: Text('✕', style: TextStyle(color: t.ink2, fontSize: 14)),
                    ),
                  ),
                  BlocBuilder<BillingBloc, BillingState>(
                    buildWhen: (p, c) => p.purchaseStatus != c.purchaseStatus,
                    builder: (context, state) => GestureDetector(
                      onTap: state.purchaseStatus == SubscriptionPurchaseStatus.pending
                          ? null
                          : () => context.read<BillingBloc>().add(const RestoreRequested()),
                      child: Text('Restore', style: TextStyle(color: t.muted, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<BillingBloc, BillingState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: t.accent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Color(0xFF0B0E11),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CardVault Pro',
                                style: TextStyle(color: t.ink2, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Unlimited scans. Every price. Every signal.',
                            style: theme.fontDisplay(fontSize: 27, color: t.ink),
                          ),
                          const SizedBox(height: 20),
                          for (final f in _features)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    '✓',
                                    style: TextStyle(color: t.up, fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(f, style: TextStyle(color: t.ink2, fontSize: 13.5))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 14),
                          state.plans.when(
                            initial: () => const Center(child: CircularProgressIndicator()),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text(
                              e is Failure ? e.error : e.toString(),
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                            data: (plans) {
                              _selectDefault(plans);
                              final yearly = firstWhereOrNull(plans, (p) => p.id == premiumYearlyProductId);
                              final monthly = firstWhereOrNull(
                                plans,
                                (p) => p.id == premiumMonthlyProductId,
                              );
                              final pending = state.purchaseStatus == SubscriptionPurchaseStatus.pending;
                              return Column(
                                children: [
                                  if (yearly != null)
                                    _PlanCard(
                                      plan: yearly,
                                      on: _selectedProductId == yearly.id,
                                      badge: 'SAVE 58%',
                                      t: t,
                                      enabled: !pending,
                                      onTap: () => setState(() => _selectedProductId = yearly.id),
                                    ),
                                  if (yearly != null && monthly != null) const SizedBox(height: 10),
                                  if (monthly != null)
                                    _PlanCard(
                                      plan: monthly,
                                      on: _selectedProductId == monthly.id,
                                      t: t,
                                      enabled: !pending,
                                      onTap: () => setState(() => _selectedProductId = monthly.id),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  final pending = state.purchaseStatus == SubscriptionPurchaseStatus.pending;
                  final plans = state.plans.valueOrNull ?? const <ProductDetails>[];
                  final selected = firstWhereOrNull(plans, (p) => p.id == _selectedProductId);
                  return GoldButton(
                    onTap: (pending || selected == null)
                        ? null
                        : () => context.read<BillingBloc>().add(PurchaseRequested(selected)),
                    label: pending ? 'Processing…' : 'Unlock CardVault Pro',
                  );
                },
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: widget.onDeclined,
                child: Text(
                  'Continue with free scans',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.muted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cancel anytime · Terms · Privacy',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.muted, fontSize: 10.5),
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
  final bool on;
  final String? badge;
  final theme.AppColors t;
  final bool enabled;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.on,
    required this.t,
    required this.onTap,
    this.badge,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: on ? t.accentBg : t.panel,
              border: Border.all(color: on ? t.accent : t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                RadioDot(on: on, t: t),
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
          if (badge != null)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Color(0xFF0B0E11), fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
