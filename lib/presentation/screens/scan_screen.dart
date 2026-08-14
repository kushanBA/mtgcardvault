import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../features/binders/domain/entities/binder.dart' as binders;
import '../../features/binders/presentation/providers/binder_providers.dart';
import '../../core/pricing/price_category.dart';
import '../../features/scan/domain/entities/card.dart';
import '../../features/scan/presentation/providers/scan_providers.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class ScanScreen extends ConsumerStatefulWidget {
  /// When set, a successful scan adds straight to this binder instead of
  /// showing the "pick a binder" flow.
  final String? targetBinderId;
  const ScanScreen({super.key, this.targetBinderId});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

enum _BurstStatus { loading, success, error }

class _BurstItem {
  final File image;
  final _BurstStatus status;
  final CardScanResult? result;
  final String? error;

  _BurstItem({
    required this.image,
    this.status = _BurstStatus.loading,
    this.result,
    this.error,
  });

  _BurstItem copyWith({
    _BurstStatus? status,
    CardScanResult? result,
    String? error,
  }) => _BurstItem(
    image: image,
    status: status ?? this.status,
    result: result ?? this.result,
    error: error ?? this.error,
  );
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CardScanResult? result;
  String? error;
  bool scanning = false;
  CameraController? controller;
  bool cameraReady = false;
  bool _disposed = false;

  bool burstMode = false;
  bool _burstProcessing = false;
  final List<File> _burstImages = [];
  List<_BurstItem> _burstResults = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return;
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.setFocusMode(FocusMode.auto);
      await c.initialize();
      if (_disposed) {
        await c.dispose();
        return;
      }
      setState(() {
        controller = c;
        cameraReady = true;
      });
    } catch (_) {
      // No camera / permission denied.
    }
  }

  Future<void> _runScan() async {
    if (scanning || controller == null || !cameraReady) return;
    setState(() {
      scanning = true;
      result = null;
      error = null;
    });
    try {
      final photo = await controller!.takePicture();

      final Directory location = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${location.path}/${photo.path}');
      log(location.toString());
      if (await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      final File file = File('${location.path}/images.jpeg');
      await photo.saveTo(file.path);
      print(file.path);
      final scanCard = ref.read(scanCardUseCaseProvider);

      final either = await scanCard(File(photo.path));
      if (_disposed) return;
      either.match(
        (failure) => setState(() {
          log('failure');
          error = failure.error;
          scanning = false;
        }),
        (r) => setState(() {
          log('corrected');
          result = r;
          scanning = false;
        }),
      );
    } catch (e) {
      if (_disposed) return;
      setState(() {
        error = e.toString();
        scanning = false;
      });
    }
  }

  void _toggleBurstMode() {
    setState(() {
      burstMode = !burstMode;
      _burstProcessing = false;
      _burstImages.clear();
      _burstResults = [];
    });
  }

  Future<void> _captureBurst() async {
    if (controller == null || !cameraReady) return;
    try {
      final photo = await controller!.takePicture();
      if (_disposed) return;
      setState(() {
        _burstImages.add(File(photo.path));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Capture failed: $e')));
    }
  }

  Future<void> _finishBurst() async {
    if (_burstImages.isEmpty) return;
    final images = List<File>.from(_burstImages);
    setState(() {
      _burstProcessing = true;
      _burstResults = images.map((f) => _BurstItem(image: f)).toList();
    });
    final scanCard = ref.read(scanCardUseCaseProvider);
    for (var i = 0; i < images.length; i++) {
      final either = await scanCard(images[i]);
      if (_disposed) return;
      setState(() {
        either.match(
          (failure) {
            _burstResults[i] = _burstResults[i].copyWith(
              status: _BurstStatus.error,
              error: failure.error,
            );
          },
          (r) {
            _burstResults[i] = _burstResults[i].copyWith(
              status: _BurstStatus.success,
              result: r,
            );
          },
        );
      });
    }
  }

  void _resetBurst() {
    setState(() {
      burstMode = false;
      _burstProcessing = false;
      _burstImages.clear();
      _burstResults = [];
    });
  }

  Future<void> _addToBinder(String catalogCardId) async {
    final t = theme.cameraTheme;
    List<binders.Binder> mtgBinders;
    try {
      final all = await ref.read(myBindersProvider.future);
      mtgBinders = all.where((b) => b.game == binders.Game.mtg).toList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load binders: $e')));
      return;
    }
    if (!mounted) return;

    final selectedBinderId = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Dialog(
        backgroundColor: t.panel,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3A3F47)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to binder',
                style: TextStyle(
                  color: t.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "MTG binders only — matches this card's game.",
                style: TextStyle(color: t.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 8),
              if (mtgBinders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No MTG binders yet — create one from the Binders tab first.',
                    style: TextStyle(color: t.muted, fontSize: 12.5),
                  ),
                ),
              ...mtgBinders.map((b) {
                return InkWell(
                  onTap: () => Navigator.of(ctx).pop(b.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF3A3F47))),
                    ),
                    child: Text(
                      b.name,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (selectedBinderId == null) return;
    final either = await ref.read(addCardToBinderUseCaseProvider)(
      selectedBinderId,
      catalogCardId,
    );
    if (!mounted) return;
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) {
        ref.invalidate(myBindersProvider);
        ref.invalidate(binderDetailProvider(selectedBinderId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to binder ✓')));
      },
    );
  }

  Future<void> _addToTargetBinder(String binderId, String catalogCardId) async {
    final either = await ref.read(addCardToBinderUseCaseProvider)(
      binderId,
      catalogCardId,
    );
    if (!mounted) return;
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) {
        ref.invalidate(myBindersProvider);
        ref.invalidate(binderDetailProvider(binderId));
        context.read<Nav>().pop();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.cameraTheme;
    final priceCategory = ref.watch(priceCategoryProvider);

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.targetBinderId != null
                        ? GestureDetector(
                            onTap: nav.pop,
                            child: Text(
                              '‹ Back',
                              style: TextStyle(color: t.muted, fontSize: 15),
                            ),
                          )
                        : Text(
                            'Scan',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    Row(
                      children: [
                        Text(
                          cameraReady ? 'camera live' : 'camera unavailable',
                          style: TextStyle(color: t.muted, fontSize: 11),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _burstProcessing ? null : _toggleBurstMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: burstMode ? t.gold : null,
                              border: Border.all(
                                color: burstMode
                                    ? t.gold
                                    : const Color(0xFF3A3F47),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              burstMode ? '📸 Burst ON' : '📸 Burst',
                              style: TextStyle(
                                color: burstMode
                                    ? const Color(0xFF131316)
                                    : t.muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (widget.targetBinderId == null) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => nav.push(NavOverlay.rip()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF3A3F47),
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '⚡ Rip Mode',
                                style: TextStyle(
                                  color: t.gold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (widget.targetBinderId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ref
                        .watch(binderDetailProvider(widget.targetBinderId!))
                        .maybeWhen(
                          data: (b) => Text(
                            'Adding to "${b.name}"',
                            style: TextStyle(
                              color: theme.gold,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          orElse: () => Text(
                            'Adding to binder…',
                            style: TextStyle(color: t.muted, fontSize: 11.5),
                          ),
                        ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _burstProcessing
                ? _buildBurstList(t, priceCategory)
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1C1C21),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (cameraReady && controller != null)
                          Builder(
                            builder: (focusContext) => GestureDetector(
                              onTapDown: (details) async {
                                final RenderBox box =
                                    focusContext.findRenderObject()
                                        as RenderBox;
                                final Offset localPosition = box.globalToLocal(
                                  details.globalPosition,
                                );
                                final Size size = box.size;
                                final Offset point = Offset(
                                  (localPosition.dx / size.width).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  (localPosition.dy / size.height).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                );
                                try {
                                  await controller!.setFocusPoint(point);
                                  await controller!.setExposurePoint(point);
                                } catch (_) {}
                              },
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width:
                                      controller!.value.previewSize?.height ??
                                      1,
                                  height:
                                      controller!.value.previewSize?.width ?? 1,
                                  child: CameraPreview(controller!),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(color: const Color(0xFF1C1C21)),
                        ..._corners(),
                        if (scanning)
                          Positioned(
                            top: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC131316),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: t.detect,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Detecting…',
                                      style: TextStyle(
                                        color: t.detect,
                                        fontSize: 12,
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
          if (!_burstProcessing)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 68),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: burstMode
                  ? Center(
                      child: Text(
                        _burstImages.isEmpty
                            ? 'Burst mode — capture cards one by one, then finish'
                            : '${_burstImages.length} photo${_burstImages.length == 1 ? '' : 's'} captured',
                        style: TextStyle(color: t.muted, fontSize: 12.5),
                      ),
                    )
                  : result != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ui.showEnlargedImage(
                                context,
                                NetworkImage(result!.card.image),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  result!.card.image,
                                  width: 34,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, err, stackTrace) =>
                                      Container(
                                        width: 34,
                                        height: 48,
                                        color: t.panel,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${result!.card.title} · ${result!.card.cardNumber}',
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${result!.card.setName} · ${result!.card.rarity}',
                                    style: TextStyle(
                                      color: t.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              result!.card.catalog != null
                                  ? '\$${result!.card.catalog!.priceFor(priceCategory).toStringAsFixed(2)}'
                                  : 'no price yet',
                              style: TextStyle(
                                color: t.detect,
                                fontSize: result!.card.catalog != null
                                    ? 17
                                    : 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (result!.card.catalogCardId != null) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: widget.targetBinderId != null
                                ? () => _addToTargetBinder(
                                    widget.targetBinderId!,
                                    result!.card.catalogCardId!,
                                  )
                                : () =>
                                      _addToBinder(result!.card.catalogCardId!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: t.gold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.targetBinderId != null
                                    ? '+ Add to this binder'
                                    : '+ Add to binder',
                                style: const TextStyle(
                                  color: Color(0xFF131316),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Center(
                      child: Text(
                        error ??
                            (scanning
                                ? 'Hold the card inside the guides…'
                                : 'Point at any card'),
                        style: TextStyle(
                          color: error != null ? Colors.redAccent : t.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
            ),
          if (_burstProcessing)
            GestureDetector(
              onTap: _resetBurst,
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF131316),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (burstMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: cameraReady ? _captureBurst : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A31),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3A3F47)),
                        ),
                        child: Text(
                          'Capture',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _burstImages.isEmpty ? null : _finishBurst,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _burstImages.isEmpty
                              ? t.gold.withValues(alpha: 0.4)
                              : t.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Finish (${_burstImages.length})',
                          style: const TextStyle(
                            color: Color(0xFF131316),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: scanning ? null : _runScan,
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scanning
                      ? 'Scanning…'
                      : (result != null ? 'Scan next card' : 'Scan'),
                  style: const TextStyle(
                    color: Color(0xFF131316),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBurstList(theme.CameraColors t, PriceCategory priceCategory) {
    final done = _burstResults
        .where((r) => r.status != _BurstStatus.loading)
        .length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Fetching card details — $done/${_burstResults.length}',
            style: TextStyle(
              color: t.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _burstResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _burstTile(t, priceCategory, _burstResults[index]),
          ),
        ),
      ],
    );
  }

  Widget _burstTile(
    theme.CameraColors t,
    PriceCategory priceCategory,
    _BurstItem item,
  ) {
    final result = item.result;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: result != null
                    ? Image.network(
                        result.card.image,
                        width: 34,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stackTrace) => Image.file(
                          item.image,
                          width: 34,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.file(
                        item.image,
                        width: 34,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: item.status == _BurstStatus.loading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: t.detect,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fetching…',
                            style: TextStyle(color: t.muted, fontSize: 12.5),
                          ),
                        ],
                      )
                    : item.status == _BurstStatus.error
                    ? Text(
                        item.error ?? 'Failed to fetch',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.5,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result!.card.title} · ${result.card.cardNumber}',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${result.card.setName} · ${result.card.rarity}',
                            style: TextStyle(color: t.muted, fontSize: 12),
                          ),
                        ],
                      ),
              ),
              if (item.status == _BurstStatus.success)
                Text(
                  result!.card.catalog != null
                      ? '\$${result.card.catalog!.priceFor(priceCategory).toStringAsFixed(2)}'
                      : 'no price yet',
                  style: TextStyle(
                    color: t.detect,
                    fontSize: result.card.catalog != null ? 17 : 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (item.status == _BurstStatus.success &&
              result!.card.catalogCardId != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.targetBinderId != null
                  ? () => _addToTargetBinder(
                      widget.targetBinderId!,
                      result.card.catalogCardId!,
                    )
                  : () => _addToBinder(result.card.catalogCardId!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.targetBinderId != null
                      ? '+ Add to this binder'
                      : '+ Add to binder',
                  style: const TextStyle(
                    color: Color(0xFF131316),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const c = Color(0xFF4ADE9E);
    Widget corner({
      double? top,
      double? bottom,
      double? left,
      double? right,
      required Border border,
    }) => Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(border: border),
      ),
    );
    return [
      corner(
        top: 18,
        left: 18,
        border: const Border(
          top: BorderSide(color: c, width: 3),
          left: BorderSide(color: c, width: 3),
        ),
      ),
      corner(
        top: 18,
        right: 18,
        border: const Border(
          top: BorderSide(color: c, width: 3),
          right: BorderSide(color: c, width: 3),
        ),
      ),
      corner(
        bottom: 18,
        left: 18,
        border: const Border(
          bottom: BorderSide(color: c, width: 3),
          left: BorderSide(color: c, width: 3),
        ),
      ),
      corner(
        bottom: 18,
        right: 18,
        border: const Border(
          bottom: BorderSide(color: c, width: 3),
          right: BorderSide(color: c, width: 3),
        ),
      ),
    ];
  }
}
