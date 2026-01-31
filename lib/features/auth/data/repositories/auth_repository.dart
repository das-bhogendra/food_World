import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';


import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/connectivity/network_info.dart';
import 'package:food_mandu/features/auth/data/datasources/auth_datasource.dart';

import 'package:food_mandu/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:food_mandu/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:food_mandu/features/auth/data/models/auth_api_model.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';

import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:food_mandu/features/auth/domain/repositories/auth_repository.dart';


/// ================= PROVIDER =================
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authLocalDatasource: ref.read(authLocalDatasourceProvider),
    authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});


/// ================= REPOSITORY IMPLEMENTATION =================
class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final INetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required INetworkInfo networkInfo,
  })  : _authLocalDatasource = authLocalDatasource,
        _authRemoteDatasource = authRemoteDatasource,
        _networkInfo = networkInfo;

  /// ================= GET CURRENT USER =================
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser();
      if (user == null) {
        return const Left(LocalDatabaseFailure(message: 'No logged-in user found'));
      }
      return Right(user.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= LOGIN =================
  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      // 1️⃣ Try offline first
      final localUser = await _authLocalDatasource.login(email, password);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // 2️⃣ If network available, try online login
      if (await _networkInfo.isConnected) {
        final remoteUser = await _authRemoteDatasource.login(email, password);
        if (remoteUser != null) {
          // Save online user to Hive for offline
          await _authLocalDatasource.register(AuthHiveModel.fromEntity(remoteUser.toEntity()));
          return Right(remoteUser.toEntity());
        } else {
          return const Left(ApiFailure(message: 'Invalid credentials'));
        }
      }

      return const Left(LocalDatabaseFailure(
        message: 'User not found offline and no network',
      ));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= LOGOUT =================
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (!result) {
        return const Left(LocalDatabaseFailure(message: 'Logout failed'));
      }
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ================= REGISTER =================
  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      // Convert to Hive and API models
      final authHiveModel = AuthHiveModel.fromEntity(user);
      final authApiModel = AuthApiModel.fromEntity(user);

      // 1️⃣ Offline first (Hive)
      if (!await _networkInfo.isConnected) {
        final exists = await _authLocalDatasource.isEmailExists(user.email);
        if (exists) {
          return const Left(LocalDatabaseFailure(message: 'Email already registered'));
        }
        final success = await _authLocalDatasource.register(authHiveModel);
        if (!success) {
          return const Left(LocalDatabaseFailure(message: 'User registration failed locally'));
        }
        return const Right(true);
      }

      // 2️⃣ Online registration (API)
      final remoteResult = await _authRemoteDatasource.register(authApiModel);
      if (remoteResult == null || remoteResult.id==null) {
        return const Left(ApiFailure(message: 'Remote registration failed'));
      }

      // 3️⃣ Save remote user to Hive for offline
      await _authLocalDatasource.register(authHiveModel);

      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, String>> uploadProfilePhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDatasource.uploadProfilePhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}