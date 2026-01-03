import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:food_mandu/core/error/failures.dart';

import 'package:food_mandu/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:food_mandu/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';



/// ================= PROVIDER =================
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDatasource: ref.read(authLocalDatasourceProvider),
  );
});

/// ================= REPOSITORY =================
class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepository({required IAuthDatasource authDatasource})
      : _authDatasource = authDatasource;

  /// ================= GET CURRENT USER =================
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: 'No current user found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= LOGIN =================
  @override
  Future<Either<Failure, AuthEntity>> login(
      String email, String password) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= LOGOUT =================
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= REGISTER =================
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // Convert Entity → Hive Model
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);

      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
