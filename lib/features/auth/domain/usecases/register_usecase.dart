import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/auth/data/repositories/auth_repository.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';



class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? batchId;
  final String username;
  final String password;
  final String confirmPassword;
  final String role;
  final String? profilePicture;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.batchId,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        batchId,
        username,
        password,
        confirmPassword,
        role,
        profilePicture,
      ];
}

final RegisterUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});




class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) async {
    final entity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      batchId: params.batchId,
      username: params.username,
      password: params.password,
      confirmPassword: params.confirmPassword,
      role: params.role,
      profilePicture: params.profilePicture,
    );

    return await _authRepository.register(entity);
  }
}
