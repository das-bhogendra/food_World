import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shakeServiceProvider = Provider<ShakeService>((ref) {
  return ShakeService();
});

class ShakeService {
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  bool _isListening = false;

  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 3.0;
  static const int _shakeCooldownMs = 1500;
  void startListening(void Function() onShakeDetected) {
    if (_isListening) return;
    
    debugPrint('Starting shake listener...');
    
    try {
      _subscription = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent event) {
          final double acceleration =
              sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

          debugPrint('Shake check - Accel: $acceleration');

          if (acceleration > _shakeThreshold) {
            final now = DateTime.now();

            if (_lastShakeTime == null ||
                now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldownMs) {
              _lastShakeTime = now;
              debugPrint('Shake detected! Acceleration: $acceleration');
              onShakeDetected();
            }
          }
        },
        onError: (error) {
          debugPrint('Shake sensor error: $error');
        },
        onDone: () {
          debugPrint('Shake sensor stream done');
        },
      );
      _isListening = true;
      debugPrint('Shake listener started successfully');
    } catch (e) {
      debugPrint('Failed to start shake listener: $e');
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _lastShakeTime = null;
  }

  void dispose() {
    stopListening();
  }
}
