import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/auth/data/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';

/// ================= USECASE PARAMS =================
class UploadPhotoUsecaseParams {
  final File photo;

  UploadPhotoUsecaseParams({required this.photo});
}

/// ================= PROVIDER =================
final uploadPhotoUsecaseProvider =
    Provider<UploadPhotoUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(authRepository: authRepository);
});

/// ================= UPLOAD PHOTO USECASE =================
class UploadPhotoUsecase
    implements
        UsecaseWithParams<String, File> { // returns URL, accepts File
  final IAuthRepository _authRepository;

  UploadPhotoUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _authRepository.uploadProfilePhoto(photo);
  }
}
