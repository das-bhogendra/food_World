import 'package:flutter/material.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/screen/splash_screen.dart';
import 'package:food_mandu/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService;

  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: SplashScreen(hiveService: hiveService), // ✅ Pass HiveService here
    );
  }
}

