import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:light/light.dart';
import 'package:food_mandu/theme/theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  Light? _light;
  StreamSubscription<num>? _lightSubscription;
  bool _manualOverride = false;
  bool _sensorAvailable = true;

  ThemeNotifier() : super(ThemeMode.light);

  bool get isManualOverride => _manualOverride;
  bool get isSensorAvailable => _sensorAvailable;

  void setManualOverride(bool value) {
    _manualOverride = value;
  }

  void setLightTheme() {
    state = ThemeMode.light;
  }

  void setDarkTheme() {
    state = ThemeMode.dark;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void startLightSensor() {
    try {
      _light = Light();
      _lightSubscription = _light?.lightSensorStream.listen(
        (luxValue) {
          debugPrint("Ambient light: ${luxValue.toDouble()} lux");
          _handleLightChange(luxValue.toDouble());
        },
        onError: (error) {
          debugPrint("Light sensor error: $error");
          _sensorAvailable = false;
        },
        onDone: () {
          debugPrint("Light sensor stream done");
          _sensorAvailable = false;
        },
      );
      debugPrint("Light sensor initialized successfully");
    } catch (e) {
      debugPrint("Could not initialize light sensor: $e");
      _sensorAvailable = false;
    }
  }

  void _handleLightChange(double luxValue) {
    if (_manualOverride) return;

    if (luxValue < 20) {
      debugPrint("Switching to dark theme (lux: $luxValue)");
      setDarkTheme();
    } else {
      debugPrint("Switching to light theme (lux: $luxValue)");
      setLightTheme();
    }
  }

  void stopLightSensor() {
    _lightSubscription?.cancel();
    _lightSubscription = null;
  }

  @override
  void dispose() {
    stopLightSensor();
    super.dispose();
  }
}

ThemeData get lightTheme => getApplicationTheme();
ThemeData get darkTheme => getApplicationDarkTheme();
