import 'package:flutter/material.dart';
import '../data/card_images.dart';

class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;
  final bool endDot;

  const Sparkline({super.key, required this.data, required this.color, required this.width, required this.height, this.endDot = true});

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(width: width, height: height);
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(data: data, color: color, endDot: endDot),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool endDot;
  _SparklinePainter({required this.data, required this.color, required this.endDot});

  @override
  void paint(Canvas canvas, Size size) {
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final span = (max - min) == 0 ? 1 : (max - min);
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * (size.width - 4) + 2;
      final y = size.height - 4 - ((data[i] - min) / span) * (size.height - 8);
      points.add(Offset(x, y));
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
    if (endDot) {
      canvas.drawCircle(points.last, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

/// Centered line-art illustration + caption for screens with nothing to show yet
class EmptyState extends StatelessWidget {
  final String image;
  final String text;
  final double size;

  const EmptyState({super.key, required this.image, required this.text, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Opacity(
              opacity: 0.95,
              child: Image.asset(image, width: size, height: size, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF6E7A8C), fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Pops a dialog showing [image] enlarged. Tapping outside it (or the ✕)
/// dismisses it — use this as the tap target for any card thumbnail.
Future<void> showEnlargedImage(BuildContext context, ImageProvider image) {
  return showDialog(
    context: context,
    barrierColor: const Color(0xE6000000),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(image: image, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Color(0xCC131316), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('✕', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Card artwork: real scan when we have one, the CardVault card back otherwise.
/// Tapping it pops an enlarged view — don't nest another tap target around it
/// for a different action; give that action its own tappable region instead.
class CardThumb extends StatelessWidget {
  final String? cardId;
  final double w;
  final double h;

  const CardThumb({super.key, this.cardId, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    final src = cardId != null ? cardImages[cardId] : null;
    final image = AssetImage(src ?? cardBack);
    return GestureDetector(
      onTap: () => showEnlargedImage(context, image),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(w * 0.06),
        child: Image(image: image, width: w, height: h, fit: BoxFit.cover),
      ),
    );
  }
}

class Chip extends StatelessWidget {
  final String label;
  final Color? bg;
  final Color color;
  final Color? border;
  final EdgeInsetsGeometry? margin;

  const Chip({super.key, required this.label, this.bg, required this.color, this.border, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: border != null ? Border.all(color: border!, width: 1) : null,
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
