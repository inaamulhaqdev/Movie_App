import 'dart:collection';
import 'dart:developer' as developer;
import 'package:flutter/scheduler.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Queue<Duration> _frameTimes = Queue<Duration>();
  int _slowFrameCount = 0;
  int _totalFrameCount = 0;

  static const int _maxStoredFrames = 120;
  static const Duration _slowFrameThreshold = Duration(milliseconds: 16);

  bool _isMonitoring = false;
  late Ticker _ticker;

  void startMonitoring(TickerProvider tickerProvider) {
    if (_isMonitoring) return;

    _slowFrameCount = 0;
    _totalFrameCount = 0;
    _frameTimes.clear();

    _ticker = tickerProvider.createTicker(_onTick);
    _ticker.start();
    _isMonitoring = true;

    developer.log('Performance monitoring started');
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;

    _ticker.stop();
    _ticker.dispose();
    _isMonitoring = false;

    developer.log('Performance monitoring stopped');
    developer.log(
      'Performance summary: $_slowFrameCount slow frames out of $_totalFrameCount (${(_slowFrameCount / _totalFrameCount * 100).toStringAsFixed(1)}%)',
    );
  }

  void _onTick(Duration elapsed) {
    _frameTimes.add(elapsed);

    if (_frameTimes.length > _maxStoredFrames) {
      _frameTimes.removeFirst();
    }

    if (_frameTimes.length >= 2) {
      final frameTime =
          _frameTimes.last - _frameTimes.elementAt(_frameTimes.length - 2);

      _totalFrameCount++;

      if (frameTime > _slowFrameThreshold) {
        _slowFrameCount++;

        if (frameTime > _slowFrameThreshold * 3) {
          developer.log(
            'Very slow frame detected: ${frameTime.inMilliseconds}ms',
            level: 1000,
          );
        }
      }
    }
  }

  double getSlowFramePercentage() {
    if (_totalFrameCount == 0) return 0;
    return _slowFrameCount / _totalFrameCount;
  }

  double getCurrentFps() {
    if (_frameTimes.length < 2) return 60.0;

    final firstFrame = _frameTimes.first;
    final lastFrame = _frameTimes.last;
    final totalDuration = lastFrame - firstFrame;

    if (totalDuration.inMilliseconds == 0) return 60.0;

    final frameCount = _frameTimes.length - 1;
    return frameCount * 1000 / totalDuration.inMilliseconds;
  }

  bool isPoorPerformance() {
    return getSlowFramePercentage() > 0.1;
  }

  String getPerformanceSummary() {
    return 'FPS: ${getCurrentFps().toStringAsFixed(1)}, '
        'Slow frames: ${(_slowFrameCount / _totalFrameCount * 100).toStringAsFixed(1)}%';
  }
}
