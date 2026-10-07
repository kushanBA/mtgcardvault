import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'sheoldred_card.dart';

/// An illustrative preview of the real scan viewfinder (see
/// `scan_screen.dart`), not a live camera. Tapping the shutter/search/burst
/// controls all "complete" this illustrative scan and move to the result
/// step; the X closes onboarding entirely.
class FirstScanStep extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onScan;

  const FirstScanStep({super.key, required this.onClose, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: t.panel),
                    child: Text('✕', style: TextStyle(color: t.ink2, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scan your first card',
                    style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '● 10 free',
                    style: TextStyle(color: t.accent, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: _Viewfinder(t: t)),
            const SizedBox(height: 12),
            Text(
              'Lay it flat · fill the frame · avoid glare',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ToolbarButton(t: t, glyph: '🔍', label: 'Search', onTap: onScan),
                GestureDetector(
                  onTap: onScan,
                  child: Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: t.accent, width: 3),
                    ),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent),
                    ),
                  ),
                ),
                _ToolbarButton(t: t, glyph: '▤', label: 'Burst', badge: 'PRO', onTap: onScan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  final theme.AppColors t;
  const _Viewfinder({required this.t});

  @override
  Widget build(BuildContext context) {
    const bracket = Color(0xFF4ADE9E);

    Widget corner({double? top, double? bottom, double? left, double? right, required Border border}) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(width: 24, height: 24, decoration: BoxDecoration(border: border)),
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF0E141D), borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCC131316),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: t.up, shape: BoxShape.circle),
                  ),
                  Text(
                    'Card detected · hold steady',
                    style: TextStyle(color: t.up, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 170,
            height: 240,
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: SheoldredCard(width: 142, height: 212),
                ),
                corner(
                  top: 0,
                  left: 0,
                  border: const Border(
                    top: BorderSide(color: bracket, width: 3),
                    left: BorderSide(color: bracket, width: 3),
                  ),
                ),
                corner(
                  top: 0,
                  right: 0,
                  border: const Border(
                    top: BorderSide(color: bracket, width: 3),
                    right: BorderSide(color: bracket, width: 3),
                  ),
                ),
                corner(
                  bottom: 0,
                  left: 0,
                  border: const Border(
                    bottom: BorderSide(color: bracket, width: 3),
                    left: BorderSide(color: bracket, width: 3),
                  ),
                ),
                corner(
                  bottom: 0,
                  right: 0,
                  border: const Border(
                    bottom: BorderSide(color: bracket, width: 3),
                    right: BorderSide(color: bracket, width: 3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final theme.AppColors t;
  final String glyph;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.t,
    required this.glyph,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
              child: Text(
                badge!,
                style: const TextStyle(color: Color(0xFF0B0E11), fontSize: 8.5, fontWeight: FontWeight.w800),
              ),
            ),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.panel),
            child: Text(glyph, style: TextStyle(color: t.ink2, fontSize: 17)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: t.muted, fontSize: 11)),
        ],
      ),
    );
  }
}
