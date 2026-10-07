import 'package:flutter/foundation.dart';
import 'data/types.dart';

enum AppTab { home, scan, binders, profile }

enum NavOverlayType {
  card,
  binder,
  sellSheet,
  rip,
  signals,
  radar,
  compare,
  show,
  search,
  scanForBinder,
  subscription,
}

class NavOverlay {
  final NavOverlayType type;
  final String? cardId;
  final Condition? condition;
  final String? binderId;
  final String? listingId;

  const NavOverlay._({
    required this.type,
    this.cardId,
    this.condition,
    this.binderId,
    this.listingId,
  });

  factory NavOverlay.card(String cardId, {Condition? condition}) =>
      NavOverlay._(
        type: NavOverlayType.card,
        cardId: cardId,
        condition: condition,
      );
  factory NavOverlay.binder(String binderId) =>
      NavOverlay._(type: NavOverlayType.binder, binderId: binderId);
  factory NavOverlay.sellSheet(String cardId, Condition condition) =>
      NavOverlay._(
        type: NavOverlayType.sellSheet,
        cardId: cardId,
        condition: condition,
      );
  factory NavOverlay.rip() => const NavOverlay._(type: NavOverlayType.rip);
  factory NavOverlay.signals() =>
      const NavOverlay._(type: NavOverlayType.signals);
  factory NavOverlay.radar() => const NavOverlay._(type: NavOverlayType.radar);
  factory NavOverlay.compare(String binderId) =>
      NavOverlay._(type: NavOverlayType.compare, binderId: binderId);
  factory NavOverlay.show(String listingId) =>
      NavOverlay._(type: NavOverlayType.show, listingId: listingId);
  factory NavOverlay.search() =>
      const NavOverlay._(type: NavOverlayType.search);
  factory NavOverlay.scanForBinder(String binderId) =>
      NavOverlay._(type: NavOverlayType.scanForBinder, binderId: binderId);
  factory NavOverlay.subscription() =>
      const NavOverlay._(type: NavOverlayType.subscription);
}

class Nav extends ChangeNotifier {
  AppTab tab = AppTab.home;
  List<NavOverlay> overlays = [];

  void setTab(AppTab t) {
    overlays = [];
    tab = t;
    notifyListeners();
  }

  void push(NavOverlay o) {
    overlays = [...overlays, o];
    notifyListeners();
  }

  void pop() {
    if (overlays.isEmpty) return;
    overlays = overlays.sublist(0, overlays.length - 1);
    notifyListeners();
  }
}
