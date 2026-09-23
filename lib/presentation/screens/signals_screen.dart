import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/error/failure.dart';
import '../../features/collection/domain/entities/collection_item.dart';
import '../../features/listings/presentation/bloc/listings_bloc.dart';
import '../../features/signals/domain/entities/signal.dart';
import '../../features/signals/presentation/bloc/signals_bloc.dart';
import '../../features/signals/presentation/bloc/signals_event.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

extension on SignalVerdict {
  String get code => switch (this) {
    SignalVerdict.sell => 'SELL',
    SignalVerdict.watch => 'WATCH',
  };
  Color get bg => switch (this) {
    SignalVerdict.sell => const Color(0x29F0544F),
    SignalVerdict.watch => const Color(0x29E3B341),
  };
  Color get ink => switch (this) {
    SignalVerdict.sell => const Color(0xFFF0544F),
    SignalVerdict.watch => const Color(0xFFE3B341),
  };
}

String _pctLabel(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SignalsBloc>()..add(const LoadMySignals())),
        BlocProvider(create: (_) => sl<ListingsBloc>()),
      ],
      child: const _SignalsView(),
    );
  }
}

class _SignalsView extends StatefulWidget {
  const _SignalsView();

  @override
  State<_SignalsView> createState() => _SignalsViewState();
}

class _SignalsViewState extends State<_SignalsView> {
  final Set<String> dismissed = {};
  final Set<String> listed = {};
  String filter = 'All';

  Future<void> _openSellDialog(Signal signal) async {
    final t = theme.light;
    final priceController = TextEditingController(
      text: signal.price.toStringAsFixed(2),
    );
    CardCondition condition = CardCondition.nm;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: t.panel,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List "${signal.name}" for sale',
                  style: TextStyle(
                    color: t.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Condition',
                  style: TextStyle(
                    color: t.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: CardCondition.values.map((c) {
                    final on = c == condition;
                    return GestureDetector(
                      onTap: () => setDialogState(() => condition = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: on ? t.ink : null,
                          border: Border.all(color: on ? t.ink : t.line),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          c.apiValue,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: on ? t.bg : t.ink2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Price',
                  style: TextStyle(
                    color: t.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: t.ink, fontSize: 14),
                  decoration: InputDecoration(
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: t.ink, fontSize: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: t.line),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: t.ink),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: t.line),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: t.ink2,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.ink,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            'List it',
                            style: TextStyle(
                              color: t.bg,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final price = double.tryParse(priceController.text.trim()) ?? signal.price;
    final either = await context.read<ListingsBloc>().createListing(
      catalogCardId: signal.catalogCardId,
      condition: condition,
      price: price,
    );
    if (!mounted) return;
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (listing) {
        setState(() => listed.add(signal.catalogCardId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Listed at \$${listing.price.toStringAsFixed(2)} ✓',
            ),
          ),
        );
      },
    );
  }

  Widget _thumb(String imageUrl, theme.AppColors t) {
    return GestureDetector(
      onTap: () => ui.showEnlargedImage(context, NetworkImage(imageUrl)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          imageUrl,
          width: 34,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, err, stack) =>
              Container(width: 34, height: 48, color: t.panel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.light;
    final signalsAsync = context.watch<SignalsBloc>().state.mySignals;

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: nav.pop,
                  child: Text(
                    '‹ Back',
                    style: TextStyle(color: t.ink2, fontSize: 14),
                  ),
                ),
                Text(
                  'Signals',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                signalsAsync.maybeWhen(
                  data: (signals) => Text(
                    '${signals.where((s) => !dismissed.contains(s.catalogCardId)).length} active',
                    style: TextStyle(color: t.muted, fontSize: 11),
                  ),
                  orElse: () => const SizedBox(width: 40),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: ['All', 'SELL', 'WATCH'].map((k) {
                final on = filter == k;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => filter = k),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: on ? t.ink : null,
                        border: Border.all(color: on ? t.ink : t.line),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        k,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: on ? t.bg : t.ink2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: signalsAsync.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    e is Failure ? e.error : e.toString(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (signals) {
                final visible = signals
                    .where(
                      (sg) =>
                          !dismissed.contains(sg.catalogCardId) &&
                          (filter == 'All' || sg.verdict.code == filter),
                    )
                    .toList();

                return RefreshIndicator(
                  onRefresh: () => context.read<SignalsBloc>().refresh(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                    children: [
                      if (visible.isEmpty)
                        const ui.EmptyState(
                          image: 'assets/illustrations/empty-signals.png',
                          text:
                              "No signals right now — you'll be pinged when the market moves on cards you own.",
                        ),
                      ...visible.map((sg) {
                        final isListed = listed.contains(sg.catalogCardId);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: t.panel,
                            border: Border.all(color: t.line),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 12,
                                ),
                                color: sg.verdict.bg,
                                child: Text(
                                  '${sg.verdict.code} SIGNAL · CONFIDENCE ${(sg.confidence * 100).round()}%',
                                  style: TextStyle(
                                    color: sg.verdict.ink,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _thumb(sg.imageUrl, t),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '${sg.name} · ${sg.setName}  ',
                                                      style: TextStyle(
                                                        color: t.ink,
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '\$${sg.price.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        color: t.up,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (sg.changePercent30d !=
                                                      null ||
                                                  sg.changePercent7d != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 2,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      if (sg.changePercent30d !=
                                                          null)
                                                        Text(
                                                          '${_pctLabel(sg.changePercent30d!)} 30d',
                                                          style: TextStyle(
                                                            color:
                                                                sg.changePercent30d! >=
                                                                    0
                                                                ? t.up
                                                                : t.down,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      if (sg.changePercent30d !=
                                                              null &&
                                                          sg.changePercent7d !=
                                                              null)
                                                        Text(
                                                          '  ·  ',
                                                          style: TextStyle(
                                                            color: t.muted,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      if (sg.changePercent7d !=
                                                          null)
                                                        Text(
                                                          '${_pctLabel(sg.changePercent7d!)} 7d',
                                                          style: TextStyle(
                                                            color:
                                                                sg.changePercent7d! >=
                                                                    0
                                                                ? t.up
                                                                : t.down,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                      top: 3,
                                                    ),
                                                child: Text(
                                                  sg.reason,
                                                  style: TextStyle(
                                                    color: t.ink2,
                                                    fontSize: 12,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: ui.Sparkline(
                                        data: sg.priceHistory,
                                        color: sg.verdict == SignalVerdict.sell
                                            ? t.down
                                            : t.up,
                                        width: 280,
                                        height: 30,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          if (sg.verdict ==
                                              SignalVerdict.sell)
                                            Expanded(
                                              flex: 13,
                                              child: isListed
                                                  ? Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            vertical: 8,
                                                          ),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            const Color(
                                                              0xFFEDEDED,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(9),
                                                      ),
                                                      child: Text(
                                                        'Listed ✓',
                                                        style: TextStyle(
                                                          color: t.ink2,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () =>
                                                          _openSellDialog(sg),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 8,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color: t.ink,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                        ),
                                                        child: Text(
                                                          'Sell now · \$${sg.price.round()}',
                                                          style: TextStyle(
                                                            color: t.bg,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          if (sg.verdict == SignalVerdict.sell)
                                            const SizedBox(width: 8),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => dismissed.add(
                                                  sg.catalogCardId,
                                                ),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: t.line,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                ),
                                                child: Text(
                                                  'Dismiss',
                                                  style: TextStyle(
                                                    color: t.ink2,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
