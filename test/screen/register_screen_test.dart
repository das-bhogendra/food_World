import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/features/auth/presentation/pages/register_screen.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  late ProviderContainer container;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue(const RegisterUsecaseParams(
      fullName: 'dummy',
      email: 'dummy@example.com',
      username: 'dummy',
      password: 'dummy',
      confirmPassword: 'dummy',
      role: 'dummy',
    ));
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockHiveService = MockHiveService();

    container = ProviderContainer(
      overrides: [
        RegisterUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        LoginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        uploadPhotoUsecaseProvider
            .overrideWith((ref) => mockUploadPhotoUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: RegisterScreen(hiveService: mockHiveService),
      ),
    );
  }

  group('RegisterScreen Widget Tests', () {
    testWidgets('should display all text fields and button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Phone Number (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text(' confirmPassword'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('should show error if required fields are empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Ensure the button is visible
      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Tap on the "Create Account" button without entering text
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Since SnackbarUtils uses context, we cannot directly verify SnackBar
      // But we can verify that register usecase is NOT called
      verifyNever(() => mockRegisterUsecase(any()));
    });

    testWidgets('should call register with correct values', (tester) async {
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());

      // Fill in all required fields
      await tester.enterText(find.byType(TextField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'johndoe');
      await tester.enterText(find.byType(TextField).at(3), '9876543210');
      await tester.enterText(find.byType(TextField).at(4), 'password123');
      await tester.enterText(find.byType(TextField).at(5), 'password123');

      // Ensure the button is visible
      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify register usecase was called once with correct parameters
      verify(() => mockRegisterUsecase(const RegisterUsecaseParams(
            fullName: 'John Doe',
            email: 'john@example.com',
            username: 'johndoe',
            password: 'password123',
            confirmPassword: 'password123',
            role: 'user',
            phoneNumber: '9876543210',
            batchId: null,
          ))).called(1);
    });

    testWidgets(
        'should navigate to login page when already have account pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Ensure the button is visible
      await tester.ensureVisible(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      // Check that LoginScreen is pushed by finding the appBar title
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    });
  });
}
