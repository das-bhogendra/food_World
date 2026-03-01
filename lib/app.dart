import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/services/shake_service.dart';
import 'package:food_mandu/screen/splash_screen.dart';
import 'package:food_mandu/screen/login_screen.dart';
import 'package:food_mandu/theme/theme.dart';

void appMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const RootWrapper(),
    ),
  );
}

/// Stateful wrapper handles shake & theme toggle
class RootWrapper extends ConsumerStatefulWidget {
  const RootWrapper({super.key});

  @override
  ConsumerState<RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends ConsumerState<RootWrapper> with WidgetsBindingObserver {
  late ShakeService _shakeService;
  bool _shakeTriggered = false;
  ThemeMode _themeMode = ThemeMode.system;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shakeService = ShakeService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShakeListener();
    });
  }

  void _startShakeListener() {
    _shakeService.startListening(() {
      debugPrint('Shake detected - triggering logout');
      if (!_shakeTriggered) {
        _shakeTriggered = true;
        _handleShakeLogout();
      }
    });
  }

  Future<void> _handleShakeLogout() async {
    // Clear Hive or implement logout logic
    await ref.read(hiveServiceProvider).clearAllData();

    // Navigate to login screen
    if (mounted && _navigatorKey.currentState != null) {
      _navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(hiveService: ref.read(hiveServiceProvider)),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _shakeTriggered = false; // reset trigger on resume
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _toggleTheme, // Double-tap to toggle theme
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme(),
        darkTheme: getApplicationDarkTheme(),
        themeMode: _themeMode,
        home: const MyApp(),
      ),
    );
  }
}

/// Your original stateless app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}