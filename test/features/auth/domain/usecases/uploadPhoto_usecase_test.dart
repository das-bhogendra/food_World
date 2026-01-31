import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UploadPhotoUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(File('dummy'));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UploadPhotoUsecase(authRepository: mockAuthRepository);
  });

  // Dummy file for testing
  final tFile = File('path/to/photo.png');
  const tUrl = 'https://example.com/photo.png';

  group('UploadPhotoUsecase', () {
    test('should return URL string when upload succeeds', () async {
      // Arrange
      when(() => mockAuthRepository.uploadProfilePhoto(any()))
          .thenAnswer((_) async => const Right(tUrl));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Right(tUrl));
      verify(() => mockAuthRepository.uploadProfilePhoto(tFile)).called(1);
    });

    test('should return Failure when upload fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Upload failed');

      when(() => mockAuthRepository.uploadProfilePhoto(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockAuthRepository.uploadProfilePhoto(tFile)).called(1);
    });

    test('should pass correct File to repository', () async {
      // Arrange
      when(() => mockAuthRepository.uploadProfilePhoto(any()))
          .thenAnswer((_) async => const Right(tUrl));

      // Act
      await usecase(tFile);

      // Assert
      final captured = verify(
        () => mockAuthRepository.uploadProfilePhoto(captureAny()),
      ).captured.first as File;

      expect(captured.path, tFile.path);
    });
  });
}
