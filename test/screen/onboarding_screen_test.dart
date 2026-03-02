import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/auth/presentation/pages/login_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';
import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/onboarding/onboarding_screen.dart';


class MockHiveService extends Mock implements HiveService {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

void main() {
  late MockHiveService mockHiveService;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;

  setUp(() {
    mockHiveService = MockHiveService();
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWith((ref) => mockHiveService),
        LoginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        RegisterUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        uploadPhotoUsecaseProvider.overrideWith((ref) => mockUploadPhotoUsecase),
      ],
      child: MaterialApp(
        home: OnboardingScreen(hiveService: mockHiveService),
      ),
    );
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('should display first onboarding page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify first page title and subtitle
      expect(find.text('Order Delicious and Tasty Food'), findsOneWidget);
      expect(find.text('Choose from top restaurants near you.'), findsOneWidget);

      // Buttons
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Indicator dots
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('should navigate pages using Next button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Go to 2nd page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Fast Home Delivery'), findsOneWidget);

      // Go to 3rd page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Easy & Secure Payments'), findsOneWidget);

      // Button should now show "Get Started"
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('should navigate to LoginScreen on Get Started press', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Tap "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify LoginScreen is shown
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should navigate to LoginScreen on Skip press', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Verify LoginScreen is shown
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
