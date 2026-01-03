import 'package:flutter/material.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before running the app
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
      title: 'FoodMandu Test',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // Pass HiveService to LoginScreen
      home: LoginScreen(hiveService: hiveService),
    );
  }
}
