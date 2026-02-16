import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';

import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';
import 'package:food_mandu/features/order/data/models/order_hive_model.dart';

import 'package:food_mandu/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Hive
  await Hive.initFlutter();

  // ✅ DEV ONLY: Delete old boxes (optional)
  if (await Hive.boxExists('authBox')) {
    await Hive.deleteBoxFromDisk('authBox');
    print('Old authBox deleted for fresh start.');
  }

  if (await Hive.boxExists('orderBox')) {
    await Hive.deleteBoxFromDisk('orderBox');
    print('Old orderBox deleted for fresh start.');
  }

  // 1b️⃣ Register Hive adapters
  Hive.registerAdapter(AuthHiveModelAdapter());
  Hive.registerAdapter(OrderItemHiveModelAdapter()); // ✅ IMPORTANT - Required for nested OrderItemHiveModel
  Hive.registerAdapter(OrderHiveModelAdapter()); // ✅ IMPORTANT

  // 1c️⃣ Open Hive boxes
  var authBox = await Hive.openBox<AuthHiveModel>('authBox');
  await Hive.openBox<OrderHiveModel>('orderBox'); // ✅ IMPORTANT

  // 1d️⃣ Read auth safely
  final auth = authBox.get('auth');
  final safeAuth = auth != null
      ? AuthHiveModel.safe(
          authId: auth.authId,
          fullName: auth.fullName,
          email: auth.email,
          phoneNumber: auth.phoneNumber,
          batchId: auth.batchId,
          username: auth.username,
          password: auth.password,
          confirmPassword: auth.confirmPassword,
          role: auth.role,
          profilePicture: auth.profilePicture,
        )
      : AuthHiveModel.safe();

  // 2️⃣ SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // 3️⃣ UserSessionService
  final userSessionService = UserSessionService(prefs: sharedPreferences);

  // 4️⃣ Run App
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveServiceProvider.overrideWithValue(HiveService()),
        userSessionServiceProvider.overrideWithValue(userSessionService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodMandu Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
