import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';
import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:food_mandu/features/auth/presentation/pages/signup_screen.dart';
import 'package:food_mandu/features/auth/presentation/pages/login_screen.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}
class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'dummy',
        email: 'dummy',
        username: 'dummy',
        password: 'dummy',
        confirmPassword: 'dummy',
        role: 'user',
        phoneNumber: null,
        batchId: null,
        profilePicture: null,
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockHiveService = MockHiveService();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        RegisterUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        LoginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        uploadPhotoUsecaseProvider.overrideWith((ref) => mockUploadPhotoUsecase),
      ],
      child: MaterialApp(
        home: SignupPage(hiveService: mockHiveService),
      ),
    );
  }

  group('SignupPage Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Phone Number (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should not call register if required fields are empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      verifyNever(() => mockRegisterUsecase(any()));
    });

    testWidgets('should call register with correct values', (tester) async {
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'johndoe');
      await tester.enterText(find.byType(TextField).at(3), '9876543210');
      await tester.enterText(find.byType(TextField).at(4), 'password123');
      await tester.enterText(find.byType(TextField).at(5), 'password123');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      verify(() => mockRegisterUsecase(
            const RegisterUsecaseParams(
              fullName: 'John Doe',
              email: 'john@example.com',
              username: 'johndoe',
              password: 'password123',
              confirmPassword: 'password123',
              role: 'user',
              phoneNumber: '9876543210',
              batchId: null,
              profilePicture: null,
            ),
          )).called(1);
    });

    testWidgets('should navigate to LoginPage when "Already have an account?" is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.ensureVisible(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsNothing);
    });
  });
}
