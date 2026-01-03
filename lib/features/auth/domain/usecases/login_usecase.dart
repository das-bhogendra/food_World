import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/auth/data/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';


/// ================= USECASE PARAMS =================
class LoginUsecaseParams extends Equatable {
  final String username;
  final String password;

  const LoginUsecaseParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [
        username,
        password,
      ];
}

final LoginUsecaseProvider = Provider<LoginUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

/// ================= LOGIN USECASE =================
class LoginUsecase
    implements UsecaseWithParams<AuthEntity?, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity?>> call(
    LoginUsecaseParams params,
  ) async {
    return await _authRepository.login(
      params.username,
      params.password,
    );
  }
}
