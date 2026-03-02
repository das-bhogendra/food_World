import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/features/onboarding/onboarding_screen.dart';
import 'package:food_mandu/features/splash/splash_screen.dart';

// Fake HiveService for testing
class FakeHiveService extends Fake implements HiveService {
  @override
  String? currentUserId;

  @override
  Future<void> init() async {}
}

void main() {
  late ProviderContainer container;
  late FakeHiveService fakeHiveService;

  setUp(() {
    fakeHiveService = FakeHiveService();
    fakeHiveService.currentUserId = null;

    container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWith((ref) => fakeHiveService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: SplashScreen(),
      ),
    );
  }

  group('SplashScreen Widget Tests', () {
    testWidgets('should display app name', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that the app name is displayed
      expect(find.text('FoodWorld'), findsOneWidget);
    });

    testWidgets('should navigate to OnboardingScreen after 2 seconds',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially SplashScreen is displayed
      expect(find.text('FoodWorld'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      // Wait for 2 seconds + a frame to allow navigation
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify that OnboardingScreen is now displayed
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
