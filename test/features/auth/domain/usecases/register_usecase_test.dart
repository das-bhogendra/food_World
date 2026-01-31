import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';

// =================== MOCK ===================
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  const tFullName = 'Test User';
  const tEmail = 'test@test.com';
  const tUsername = 'testuser';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';
  const tRole = 'user';
  const tPhoneNumber = '1234567890';
  const tBatchId = 'batch001';
  const tProfilePicture = 'profile.png';

  const tParams = RegisterUsecaseParams(
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    password: tPassword,
    confirmPassword: tConfirmPassword,
    role: tRole,
    phoneNumber: tPhoneNumber,
    batchId: tBatchId,
    profilePicture: tProfilePicture,
  );

  
  const tAuthEntity = AuthEntity(
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    password: tPassword,
    confirmPassword: tConfirmPassword,
    role: tRole,
    phoneNumber: tPhoneNumber,
    batchId: tBatchId,
    profilePicture: tProfilePicture,
  );

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(() => mockAuthRepository.register(tAuthEntity))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Registration failed');
      when(() => mockAuthRepository.register(tAuthEntity))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });

  group('RegisterUsecaseParams', () {
    test('should have correct props', () {
      expect(
        tParams.props,
        [
          tFullName,
          tEmail,
          tPhoneNumber,
          tBatchId,
          tUsername,
          tPassword,
          tConfirmPassword,
          tRole,
          tProfilePicture
        ],
      );
    });

    test('two params with same values should be equal', () {
      const params1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        role: tRole,
        phoneNumber: tPhoneNumber,
        batchId: tBatchId,
        profilePicture: tProfilePicture,
      );

      const params2 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        role: tRole,
        phoneNumber: tPhoneNumber,
        batchId: tBatchId,
        profilePicture: tProfilePicture,
      );

      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      const params1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        role: tRole,
      );

      const params2 = RegisterUsecaseParams(
        fullName: 'Other User',
        email: 'other@test.com',
        username: 'otheruser',
        password: '123',
        confirmPassword: '123',
        role: 'admin',
      );

      expect(params1, isNot(params2));
    });
  });
}
