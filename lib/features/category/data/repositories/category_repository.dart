import 'package:dartz/dartz.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/connectivity/network_info.dart';
import 'package:food_mandu/features/category/data/datasources/category_datasource.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

import '../models/category_api_model.dart';
import '../models/category_hive_model.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final ICategoryLocalDatasource _localDataSource;
  final ICategoryRemoteDatasource _remoteDataSource;
  final INetworkInfo _networkInfo;

  CategoryRepositoryImpl({
    required ICategoryLocalDatasource localDatasource,
    required ICategoryRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  })  : _localDataSource = localDatasource,
        _remoteDataSource = remoteDatasource,
        _networkInfo = networkInfo;

  /// ================= CREATE =================
  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity category) async {
    try {
      final apiModel = CategoryApiModel.fromEntity(category);

      if (await _networkInfo.isConnected) {
        // Online: create remote & save locally
        final remoteResult = await _remoteDataSource.createCategory(apiModel);
        final hiveModel = CategoryHiveModel.fromEntity(remoteResult.toEntity());
        await _localDataSource.createCategory(hiveModel);
      } else {
        // Offline: generate temporary ID
        final offlineCategory = CategoryEntity(
          id: category.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : category.id,
          name: category.name,
          description: category.description,
          createdBy: category.createdBy,
          createdAt: category.createdAt ?? DateTime.now(),
        );
        final hiveModel = CategoryHiveModel.fromEntity(offlineCategory);
        await _localDataSource.createCategory(hiveModel);
      }

      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  /// ================= UPDATE =================
  @override
  Future<Either<Failure, bool>> updateCategory(CategoryEntity category) async {
    try {
      final apiModel = CategoryApiModel.fromEntity(category);

      if (await _networkInfo.isConnected) {
        final remoteResult = await _remoteDataSource.updateCategory(apiModel);
        final hiveModel = CategoryHiveModel.fromEntity(remoteResult.toEntity());
        await _localDataSource.updateCategory(hiveModel);
      } else {
        final hiveModel = CategoryHiveModel.fromEntity(category);
        await _localDataSource.updateCategory(hiveModel);
      }

      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  /// ================= DELETE =================
  @override
  Future<Either<Failure, bool>> deleteCategory(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteResult = await _remoteDataSource.deleteCategory(id);
        if (remoteResult) {
          await _localDataSource.deleteCategory(id);
          return const Right(true);
        } else {
          return Left(ApiFailure(message: "Failed to delete from server"));
        }
      } else {
        final localResult = await _localDataSource.deleteCategory(id);
        if (localResult) {
          return const Right(true);
        } else {
          return Left(LocalDatabaseFailure(message: "Category not found locally"));
        }
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  /// ================= GET ALL =================
  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteList = await _remoteDataSource.getAllCategories();

        // Save all to local
        for (final apiCategory in remoteList) {
          final hiveModel = CategoryHiveModel.fromEntity(apiCategory.toEntity());
          await _localDataSource.createCategory(hiveModel);
        }

        return Right(remoteList.map((e) => e.toEntity()).toList());
      } else {
        final localList = await _localDataSource.getAllCategories();
        return Right(localList.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      // If network fails, fallback to local
      final localList = await _localDataSource.getAllCategories();
      return Right(localList.map((e) => e.toEntity()).toList());
    }
  }

  /// ================= GET BY ID =================
  @override
  Future<Either<Failure, CategoryEntity?>> getCategoryById(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        final remote = await _remoteDataSource.getCategoryById(id);
        if (remote == null) {
          return Left(ApiFailure(message: "Category not found on server"));
        }

        final hiveModel = CategoryHiveModel.fromEntity(remote.toEntity());
        await _localDataSource.updateCategory(hiveModel);

        return Right(remote.toEntity());
      } else {
        final local = await _localDataSource.getCategoryById(id);
        return Right(local?.toEntity());
      }
    } catch (e) {
      final local = await _localDataSource.getCategoryById(id);
      return Right(local?.toEntity());
    }
  }

  /// ================= GET BY USER =================
  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByUser(String userId) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteList = await _remoteDataSource.getCategoriesByUser(userId);

        for (final apiCategory in remoteList) {
          final hiveModel = CategoryHiveModel.fromEntity(apiCategory.toEntity());
          await _localDataSource.createCategory(hiveModel);
        }

        return Right(remoteList.map((e) => e.toEntity()).toList());
      } else {
        final localList = await _localDataSource.getCategoriesByUser(userId);
        return Right(localList.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      final localList = await _localDataSource.getCategoriesByUser(userId);
      return Right(localList.map((e) => e.toEntity()).toList());
    }
  }
}
