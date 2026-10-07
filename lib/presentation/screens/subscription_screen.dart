import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/bloc/resource.dart';
import '../../core/error/failure.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/billing/presentation/bloc/billing_event.dart';
import '../../features/billing/presentation/bloc/billing_state.dart';
import '../../features/billing/subscription_product_ids.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;

// TEMPORARY — shows a fake plan card instead of querying the real store, so
// the screen can be screenshotted for App Store Connect's subscription
// review-screenshot requirement while "premium members" is still in Draft
// (and therefore unqueryable). No StoreKit/Play Billing call is made at all
// — neither the product query nor a purchase — while this is on. Set to
// false (or delete this + its two usages below) once the real product
// resolves and you're done capturing the screenshot.
const kMockPremiumScreenForScreenshot = false;

final _mockPlan = ProductDetails(
  id: 'premium_yearly',
  title: 'CardVault Premium — Yearly',
  description: 'Unlimited scans, Signals and Deal Radar. Billed annually.',
  price: '\$0.99',
  rawPrice: 0.99,
  currencyCode: 'USD',
  currencySymbol: '\$',
);

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    if (kMockPremiumScreenForScreenshot) return;
    final bloc = context.read<BillingBloc>();
    if (bloc.state.plans is ResourceInitial) {
      bloc.add(const LoadPlans(subscriptionProductIds));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final nav = context.read<Nav>();

    return BlocListener<BillingBloc, BillingState>(
      listenWhen: (previous, current) =>
          previous.purchaseStatus != current.purchaseStatus,
      listener: (context, state) {
        switch (state.purchaseStatus) {
          case SubscriptionPurchaseStatus.success:
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Subscribed ✓')));
            nav.pop();
          case SubscriptionPurchaseStatus.error:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Purchase failed.')),
            );
          case SubscriptionPurchaseStatus.idle:
          case SubscriptionPurchaseStatus.pending:
            break;
        }
      },
      child: Container(
        color: t.bg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: nav.pop,
                      child: Text(
                        '‹ Back',
                        style: TextStyle(color: t.muted, fontSize: 15),
                      ),
                    ),
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: kMockPremiumScreenForScreenshot
                    ? ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          Text(
                            'Unlock unlimited scans, Signals and Deal Radar.',
                            style: TextStyle(color: t.ink2, fontSize: 13.5),
                          ),
                          const SizedBox(height: 18),
                          _PlanTile(plan: _mockPlan, t: t, interactive: false),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'Restore purchases',
                              style: TextStyle(
                                color: t.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : BlocBuilder<BillingBloc, BillingState>(
                        builder: (context, state) => state.plans.when(
                          initial: () =>
                              const Center(child: CircularProgressIndicator()),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                e is Failure ? e.error : e.toString(),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          data: (plans) => ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              Text(
                                'Unlock unlimited scans, Signals and Deal Radar.',
                                style: TextStyle(color: t.ink2, fontSize: 13.5),
                              ),
                              const SizedBox(height: 18),
                              ...plans.map(
                                (plan) =>
                                    _PlanTile(plan: plan, t: t, state: state),
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: GestureDetector(
                                  onTap:
                                      state.purchaseStatus ==
                                          SubscriptionPurchaseStatus.pending
                                      ? null
                                      : () => context.read<BillingBloc>().add(
                                          const RestoreRequested(),
                                        ),
                                  child: Text(
                                    'Restore purchases',
                                    style: TextStyle(
                                      color: t.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final ProductDetails plan;
  final theme.AppColors t;
  final BillingState? state;
  final bool interactive;

  const _PlanTile({
    required this.plan,
    required this.t,
    this.state,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final pending = state?.purchaseStatus == SubscriptionPurchaseStatus.pending;
    return GestureDetector(
      onTap: (!interactive || pending)
          ? null
          : () => context.read<BillingBloc>().add(PurchaseRequested(plan)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.panel,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    plan.description,
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            pending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.accent,
                    ),
                  )
                : Text(
                    plan.price,
                    style: TextStyle(
                      color: t.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
