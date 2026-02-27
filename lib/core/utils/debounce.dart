import 'dart:async';
import 'dart:ui';

/// Debouncer utility to prevent rapid-fire API calls.
///
/// Used primarily for search input — waits for the user to stop
/// typing for [delay] milliseconds before executing the action.
///
/// Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
/// debouncer.run(() => performSearch(query));
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  /// Schedules [action] to run after [milliseconds] delay.
  /// If called again before the delay expires, the previous
  /// scheduled action is cancelled and a new one is scheduled.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a debounced action is currently pending
  bool get isPending => _timer?.isActive ?? false;

  /// Disposes the debouncer — call when no longer needed
  void dispose() {
    cancel();
  }
}
