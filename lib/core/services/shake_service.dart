import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isListening = false;

  DateTime? _lastShakeTime;

  static const double _shakeThreshold = 15.0;
  static const int _shakeCooldownMs = 500;

  void startListening(void Function() onShakeDetected) {
    if (_isListening) return;

    print('[ShakeService] Starting shake listener...');

    try {
      print('[ShakeService] Trying to start accelerometer...');
      
      final stream = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 100),
      );
      
      _subscription = stream.listen(
        (AccelerometerEvent event) {
          final double acceleration = sqrt(
            event.x * event.x + 
            event.y * event.y + 
            event.z * event.z,
          );

          if (kDebugMode) {
            print('[ShakeService] Accel: ${acceleration.toStringAsFixed(2)}');
          }

          if (acceleration > _shakeThreshold) {
            final now = DateTime.now();

            if (_lastShakeTime == null ||
                now.difference(_lastShakeTime!).inMilliseconds >=
                    _shakeCooldownMs) {

              _lastShakeTime = now;

              print('[ShakeService] Shake detected! Accel: ${acceleration.toStringAsFixed(2)}');

              onShakeDetected();
            }
          }
        },
        onError: (error) {
          print('[ShakeService] Sensor error: $error');
        },
        onDone: () {
          print('[ShakeService] Stream closed');
        },
      );

      _isListening = true;
      print('[ShakeService] Listener started successfully');
    } catch (e) {
      print('[ShakeService] Failed to start: $e');
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _lastShakeTime = null;
    debugPrint('[ShakeService] Listener stopped');
  }

  void dispose() {
    stopListening();
  }
}
