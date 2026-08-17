import 'dart:async';
import 'dart:collection';

/// Sliding-window limiter used internally by the client.
class RateLimiter {
  RateLimiter({
    this.maxRequests = 90,
    this.period = const Duration(minutes: 1),
  })  : assert(maxRequests >= 1),
        assert(period.inMilliseconds > 0);

  final int maxRequests;
  final Duration period;
  final Queue<DateTime> _timestamps = Queue<DateTime>();

  Future<void> acquire() async {
    while (true) {
      final now = DateTime.now();
      final cutoff = now.subtract(period);
      while (_timestamps.isNotEmpty && !_timestamps.first.isAfter(cutoff)) {
        _timestamps.removeFirst();
      }

      if (_timestamps.length < maxRequests) {
        _timestamps.addLast(now);
        return;
      }

      final wait = _timestamps.first.add(period).difference(now);
      if (wait > Duration.zero) {
        await Future<void>.delayed(wait);
      }
    }
  }
}
