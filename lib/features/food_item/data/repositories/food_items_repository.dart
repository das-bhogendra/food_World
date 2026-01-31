import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/connectivity/network_info.dart';
import 'package:food_mandu/features/food_item/data/datasources/food_items_datasource.dart';
import 'package:food_mandu/features/food_item/data/datasources/local/food_items_localdatasource.dart';
import 'package:food_mandu/features/food_item/data/datasources/remote/food_items_remotedatasource.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_hive_model.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

/// Provider for the FoodItemsRepository
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

/// Repository implementation
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

  // ---------------- CRUD ----------------

  @override
  Future<Either<Failure, bool>> createFoodItem(FoodItemEntity item) async {
    try {
      final itemModel = FoodItemHiveModel.fromEntity(item);
      final result = await _localDataSource.createFoodItem(itemModel);
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: "Failed to create food item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateFoodItem(FoodItemEntity item) async {
    try {
      final itemModel = FoodItemHiveModel.fromEntity(item);
      final result = await _localDataSource.updateFoodItem(itemModel);
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: "Failed to update food item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFoodItem(String id) async {
    try {
      final result = await _localDataSource.deleteFoodItem(id);
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: "Failed to delete food item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItemEntity>>> getAllFoodItems() async {
    try {
      final models = await _localDataSource.getAllFoodItems();
      final entities = FoodItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodItemEntity>> getFoodItemById(String id) async {
    try {
      final model = await _localDataSource.getFoodItemById(id);
      if (model != null) return Right(model.toEntity());
      return Left(LocalDatabaseFailure(message: 'Food item not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByUser(String userId) async {
    try {
      final models = await _localDataSource.getFoodItemsByUser(userId);
      final entities = FoodItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByType(FoodItemType type) async {
    try {
      final models = await _localDataSource.getFoodItemsByType(type.name);
      final entities = FoodItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
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
      return  Left(NetworkFailure(message: 'No internet connection'));
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
      return  Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
