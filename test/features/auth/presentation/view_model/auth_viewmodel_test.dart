import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';
import 'package:food_mandu/features/auth/presentation/state/auth_state.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

void main() {
  late ProviderContainer container;
  late MockRegisterUsecase mockRegister;
  late MockLoginUsecase mockLogin;
  late MockUploadPhotoUsecase mockUploadPhoto;

  setUpAll(() {
    registerFallbackValue(File('dummy'));
    registerFallbackValue(const RegisterUsecaseParams(
      fullName: 'dummy',
      email: 'dummy@example.com',
      username: 'dummy',
      password: 'dummy',
      confirmPassword: 'dummy',
      role: 'dummy',
    ));
    registerFallbackValue(const LoginUsecaseParams(
      username: 'dummy',
      password: 'dummy',
    ));
  });

  setUp(() {
    mockRegister = MockRegisterUsecase();
    mockLogin = MockLoginUsecase();
    mockUploadPhoto = MockUploadPhotoUsecase();

    container = ProviderContainer(
      overrides: [
        // Override the usecase providers with mocks
        RegisterUsecaseProvider.overrideWith((ref) => mockRegister),
        LoginUsecaseProvider.overrideWith((ref) => mockLogin),
        uploadPhotoUsecaseProvider.overrideWith((ref) => mockUploadPhoto),
      ],
    );


  });

  tearDown(() {
    container.dispose();
  });

  const tFullName = 'Test User';
  const tEmail = 'test@test.com';
  const tUsername = 'testuser';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';
  const tRole = 'user';
  final tFile = File('path/to/photo.png');
  const tUrl = 'https://example.com/photo.png';

  const tAuthEntity = AuthEntity(
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    password: tPassword,
    confirmPassword: tConfirmPassword,
    role: tRole,
  );

  group('AuthViewModel - register', () {
    test('should update state to registered on success', () async {
      when(() => mockRegister(any()))
          .thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).register(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        role: tRole,
      );

      expect(container.read(authViewModelProvider).status, AuthStatus.registered);
      verify(() => mockRegister(any())).called(1);
    });

    test('should update state to error on failure', () async {
      const failure = ApiFailure(message: 'Registration failed');

      when(() => mockRegister(any()))
          .thenAnswer((_) async => const Left(failure));

      await container.read(authViewModelProvider.notifier).register(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        role: tRole,
      );

      expect(container.read(authViewModelProvider).status, AuthStatus.error);
      expect(container.read(authViewModelProvider).errorMessage, 'Registration failed');
    });
  });

  group('AuthViewModel - login', () {
    test('should update state to authenticated on success', () async {
      when(() => mockLogin(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await container.read(authViewModelProvider.notifier).login(
        username: tUsername,
        password: tPassword,
      );

      expect(container.read(authViewModelProvider).status, AuthStatus.authenticated);
      expect(container.read(authViewModelProvider).authEntity, tAuthEntity);
      verify(() => mockLogin(any())).called(1);
    });

    test('should update state to error on failure', () async {
      const failure = ApiFailure(message: 'Invalid credentials');

      when(() => mockLogin(any()))
          .thenAnswer((_) async => const Left(failure));

      await container.read(authViewModelProvider.notifier).login(
        username: tUsername,
        password: tPassword,
      );

      expect(container.read(authViewModelProvider).status, AuthStatus.error);
      expect(container.read(authViewModelProvider).errorMessage, 'Invalid credentials');
    });
  });

  group('AuthViewModel - uploadPhoto', () {
    test('should return URL and update state on success', () async {
      when(() => mockUploadPhoto(any()))
          .thenAnswer((_) async => const Right(tUrl));

      final result = await container.read(authViewModelProvider.notifier).uploadPhoto(tFile);

      expect(result, tUrl);
      expect(container.read(authViewModelProvider).uploadedPhotoUrl, tUrl);
      verify(() => mockUploadPhoto(tFile)).called(1);
    });

    test('should return null and update state on failure', () async {
      const failure = ApiFailure(message: 'Upload failed');

      when(() => mockUploadPhoto(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await container.read(authViewModelProvider.notifier).uploadPhoto(tFile);

      expect(result, null);
      expect(container.read(authViewModelProvider).status, AuthStatus.error);
      expect(container.read(authViewModelProvider).errorMessage, 'Upload failed');
    });
  });

  group('AuthViewModel - clearError', () {
    test('should clear errorMessage', () {
      container.read(authViewModelProvider.notifier).state = const AuthState(errorMessage: null);
      container.read(authViewModelProvider.notifier).clearError();
      expect(container.read(authViewModelProvider).errorMessage, null);
    });
  });
}
