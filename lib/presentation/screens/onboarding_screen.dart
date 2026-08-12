import 'package:flutter/material.dart';
import '../../theme.dart' as theme;

class _Slide {
  final String image;
  final String title;
  final String body;
  const _Slide({required this.image, required this.title, required this.body});
}

const _slides = [
  _Slide(
    image: 'assets/illustrations/onboard-scan.png',
    title: 'Scan any card, know its true price',
    body: 'Point the camera at a card — real sold prices from every marketplace, not asking prices, in two seconds.',
  ),
  _Slide(
    image: 'assets/illustrations/onboard-binder.png',
    title: 'Your binder is a portfolio',
    body: 'Nine pockets, live values, daily gains and losses — your collection tracked like a trading account.',
  ),
  _Slide(
    image: 'assets/illustrations/onboard-sell.png',
    title: 'Sell with proof',
    body: 'AI-checked condition, verified scan photos, and every fee shown before you publish. Buyers trust what they can verify.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final last = i == _slides.length - 1;
    final slide = _slides[i];

    return Container(
      color: t.bg,
      child: Stack(
        children: [
          Positioned(
            top: 18,
            right: 20,
            child: GestureDetector(
              onTap: widget.onDone,
              child: Text('Skip', style: TextStyle(color: t.muted, fontSize: 13)),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.46,
                  child: Image.asset(slide.image, fit: BoxFit.contain),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        slide.title,
                        style: theme.fontDisplay(fontSize: 24, color: t.ink),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide.body,
                        style: TextStyle(color: t.ink2, fontSize: 14.5, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(_slides.length, (d) {
                          final active = d == i;
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 18 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active ? t.accent : t.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: () => last ? widget.onDone() : setState(() => i += 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                          decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            last ? 'Start scanning' : 'Next',
                            style: TextStyle(color: t.bg, fontSize: 14, fontWeight: FontWeight.w700),
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
  }
}
