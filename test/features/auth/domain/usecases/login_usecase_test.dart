import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  const tUsername = 'testuser';
  const tPassword = 'password123';

  const tParams = LoginUsecaseParams(
    username: tUsername,
    password: tPassword,
  );

  // ✅ Fully corrected AuthEntity with username
  const tAuthEntity = AuthEntity(
    authId: '1',
    username: tUsername,
    fullName: 'Test User',
    email: 'test@test.com',
    password: 'password123',
    confirmPassword: 'password123',
    role: 'user',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase(tParams);

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.login(tUsername, tPassword)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when login fails', () async {
      const failure = ApiFailure(message: 'Invalid credentials');

      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left(failure));
      verify(() => mockAuthRepository.login(tUsername, tPassword)).called(1);
    });

    test('should pass correct username and password to repository', () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await usecase(tParams);

      final captured = verify(() =>
              mockAuthRepository.login(captureAny(), captureAny()))
          .captured;

      expect(captured[0], tUsername);
      expect(captured[1], tPassword);
    });
  });

  group('LoginUsecaseParams', () {
    test('should have correct props', () {
      expect(tParams.props, [tUsername, tPassword]);
    });

    test('two params with same values should be equal', () {
      const params1 = LoginUsecaseParams(
        username: tUsername,
        password: tPassword,
      );
      const params2 = LoginUsecaseParams(
        username: tUsername,
        password: tPassword,
      );

      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      const params1 = LoginUsecaseParams(
        username: tUsername,
        password: tPassword,
      );
      const params2 = LoginUsecaseParams(
        username: 'other',
        password: '123',
      );

      expect(params1, isNot(params2));
    });
  });
}
