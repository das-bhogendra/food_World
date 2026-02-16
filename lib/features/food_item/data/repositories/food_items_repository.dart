import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/connectivity/network_info.dart';
import 'package:food_mandu/features/food_item/data/datasources/food_items_datasource.dart';
import 'package:food_mandu/features/food_item/data/datasources/local/food_items_localdatasource.dart';
import 'package:food_mandu/features/food_item/data/datasources/remote/food_items_remotedatasource.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_api_model.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_hive_model.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

final foodItemsRepositoryProvider = Provider<IFoodItemsRepository>((ref) {
  final localDatasource = ref.read(foodItemLocalDatasourceProvider);
  final remoteDatasource = ref.read(foodItemsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return FoodItemsRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class FoodItemsRepository implements IFoodItemsRepository {
  final IFoodItemsLocalDatasource _localDataSource;
  final IFoodItemsRemoteDataSource _remoteDataSource;
  final INetworkInfo _networkInfo;

  FoodItemsRepository({
    required IFoodItemsLocalDatasource localDatasource,
    required IFoodItemsRemoteDataSource remoteDatasource,
    required INetworkInfo networkInfo,
  })  : _localDataSource = localDatasource,
        _remoteDataSource = remoteDatasource,
        _networkInfo = networkInfo;

  // ---------------- CREATE ----------------
  @override
  Future<Either<Failure, bool>> createFoodItem(
    FoodItemEntity item, {
    File? imageFile,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final apiModel = FoodItemApiModel.fromEntity(item);

        final remoteModel = await _remoteDataSource.createFoodItem(
          apiModel,
          imageFile: imageFile,
        );

        await (_localDataSource as FoodItemLocalDatasource)
            .createOrUpdateFoodItem(
          FoodItemHiveModel.fromEntity(remoteModel.toEntity()),
        );

        return const Right(true);
      } else {
        final itemModel = FoodItemHiveModel.fromEntity(item);
        final result = await _localDataSource.createFoodItem(itemModel);

        return result
            ? const Right(true)
            : Left(LocalDatabaseFailure(
                message: "Failed to create food item offline",
              ));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- UPDATE ----------------
  @override
  Future<Either<Failure, bool>> updateFoodItem(
    FoodItemEntity item, {
    File? imageFile,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final apiModel = FoodItemApiModel.fromEntity(item);

        final remoteModel = await _remoteDataSource.updateFoodItem(
          apiModel,
          imageFile: imageFile,
        );

        await (_localDataSource as FoodItemLocalDatasource)
            .createOrUpdateFoodItem(
          FoodItemHiveModel.fromEntity(remoteModel.toEntity()),
        );

        return const Right(true);
      } else {
        final itemModel = FoodItemHiveModel.fromEntity(item);
        final result = await _localDataSource.updateFoodItem(itemModel);

        return result
            ? const Right(true)
            : Left(LocalDatabaseFailure(
                message: "Failed to update food item offline",
              ));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- DELETE ----------------
  @override
  Future<Either<Failure, bool>> deleteFoodItem(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.deleteFoodItem(id);
        await _localDataSource.deleteFoodItem(id);
        return const Right(true);
      } else {
        final result = await _localDataSource.deleteFoodItem(id);
        return result
            ? const Right(true)
            : Left(LocalDatabaseFailure(message: "Failed to delete offline"));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- GET ALL ----------------
  @override
  Future<Either<Failure, List<FoodItemEntity>>> getAllFoodItems() async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteModels = await _remoteDataSource.getAllFoodItems();
        final entities = FoodItemApiModel.toEntityList(remoteModels);

        for (var entity in entities) {
          await (_localDataSource as FoodItemLocalDatasource)
              .createOrUpdateFoodItem(
            FoodItemHiveModel.fromEntity(entity),
          );
        }

        return Right(entities);
      } else {
        final localModels = await _localDataSource.getAllFoodItems();
        final entities = FoodItemHiveModel.toEntityList(localModels);
        return Right(entities);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- GET BY ID ----------------
  @override
  Future<Either<Failure, FoodItemEntity>> getFoodItemById(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteModel = await _remoteDataSource.getFoodItemById(id);

        if (remoteModel == null) {
          return Left(LocalDatabaseFailure(message: "Food item not found"));
        }

        final entity = remoteModel.toEntity();

        await (_localDataSource as FoodItemLocalDatasource)
            .createOrUpdateFoodItem(
          FoodItemHiveModel.fromEntity(entity),
        );

        return Right(entity);
      } else {
        final localModel = await _localDataSource.getFoodItemById(id);

        if (localModel != null) return Right(localModel.toEntity());

        return Left(LocalDatabaseFailure(message: "Food item not found offline"));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- GET BY USER ----------------
  @override
  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByUser(
      String userId) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteModels = await _remoteDataSource.getFoodItemsByUser(userId);

        final entities = FoodItemApiModel.toEntityList(remoteModels);

        for (var entity in entities) {
          await (_localDataSource as FoodItemLocalDatasource)
              .createOrUpdateFoodItem(
            FoodItemHiveModel.fromEntity(entity),
          );
        }

        return Right(entities);
      } else {
        final localModels = await _localDataSource.getFoodItemsByUser(userId);
        final entities = FoodItemHiveModel.toEntityList(localModels);
        return Right(entities);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- GET BY TYPE ----------------
  @override
  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByType(
      FoodItemType type) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteModels = await _remoteDataSource.getFoodItemsByType(type.name);

        final entities = FoodItemApiModel.toEntityList(remoteModels);

        for (var entity in entities) {
          await (_localDataSource as FoodItemLocalDatasource)
              .createOrUpdateFoodItem(
            FoodItemHiveModel.fromEntity(entity),
          );
        }

        return Right(entities);
      } else {
        final localModels = await _localDataSource.getFoodItemsByType(type.name);
        final entities = FoodItemHiveModel.toEntityList(localModels);
        return Right(entities);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ---------------- MEDIA ----------------
  @override
  Future<Either<Failure, String>> uploadFoodPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFoodVideo(File video) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadVideo(video);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }
}
