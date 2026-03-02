import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/auth/presentation/pages/login_screen.dart';
import 'package:food_mandu/features/auth/presentation/pages/signup_screen.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}
class MockHiveService extends Mock implements HiveService {}

void main() {
  late ProviderContainer container;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue(const LoginUsecaseParams(
      username: 'dummy',
      password: 'dummy',
    ));
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockHiveService = MockHiveService();

    container = ProviderContainer(
      overrides: [
        RegisterUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        LoginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        uploadPhotoUsecaseProvider.overrideWith((ref) => mockUploadPhotoUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        RegisterUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        LoginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        uploadPhotoUsecaseProvider.overrideWith((ref) => mockUploadPhotoUsecase),
      ],
      child: MaterialApp(
        home: LoginPage(hiveService: mockHiveService),
      ),
    );
  }


  group('LoginPage Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsNWidgets(2)); // App bar title and button text
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Login to continue to FoodWorld'), findsOneWidget);

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.byKey(const Key('register_link')), findsOneWidget);
    });

    testWidgets('should not call login if fields are empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      verifyNever(() => mockLoginUsecase(any()));
    });

    testWidgets('should call login with correct values', (tester) async {
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => const Right(null)); // Mock successful login

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      verify(() => mockLoginUsecase(const LoginUsecaseParams(
            username: 'test@example.com',
            password: 'password123',
          ))).called(1);
    });

    testWidgets('should navigate to SignupPage when register link is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('register_link')));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsOneWidget);
    });
  });
}
