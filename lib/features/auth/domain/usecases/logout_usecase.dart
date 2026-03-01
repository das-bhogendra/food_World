import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/auth/data/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';

/// ------------------- PROVIDER -------------------
final LogoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

/// ------------------- USECASE -------------------
class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() async {
    // Call logout from the repository
    return await _authRepository.logout();
  }
}

/// ------------------- NO PARAMS -------------------
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
