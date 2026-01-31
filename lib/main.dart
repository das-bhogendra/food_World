import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';
import 'package:food_mandu/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Hive
  await Hive.initFlutter();

  // 1a️⃣ Delete old Hive box safely (dev only)
  if (await Hive.boxExists('authBox')) {
    await Hive.deleteBoxFromDisk('authBox');
    print('Old authBox deleted for fresh start.');
  }

  // 1b️⃣ Register Hive adapter
  Hive.registerAdapter(AuthHiveModelAdapter());

  // 1c️⃣ Open Hive box safely
  var authBox = await Hive.openBox<AuthHiveModel>('authBox');

  // 1d️⃣ Read safely from Hive using safe factory
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

  // 2️⃣ Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // 3️⃣ Create UserSessionService
  final userSessionService = UserSessionService(prefs: sharedPreferences);

  // 4️⃣ Run App with ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveServiceProvider.overrideWithValue(HiveService()), // Optional if you still use HiveService
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
