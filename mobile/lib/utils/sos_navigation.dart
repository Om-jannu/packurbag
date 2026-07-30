import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

DateTime? _lastSosNavigationAt;

/// Pushes the SOS screen, ignoring a repeat tap within a second of the last
/// one — the screen has two separate entry points (the speed-dial FAB and
/// the home quick-action tile), and a fast double-tap on either would
/// otherwise push it twice, creating two independent countdown timers.
void navigateToSos(BuildContext context) {
  final now = DateTime.now();
  if (_lastSosNavigationAt != null &&
      now.difference(_lastSosNavigationAt!) < const Duration(seconds: 1)) {
    return;
  }
  _lastSosNavigationAt = now;
  context.push('/sos');
}
