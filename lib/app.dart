import 'package:flutter/material.dart';
import 'package:food_mandu/screen/splash_screen.dart';
import 'package:food_mandu/theme/theme.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),  // ✅ Works now
      home: const SplashScreen(),
    );
  }
  
}
