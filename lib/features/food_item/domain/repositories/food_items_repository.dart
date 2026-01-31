import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:food_mandu/core/error/failures.dart';
import '../entities/food_items_entity.dart';

abstract interface class IFoodItemsRepository {
  /// ================= GET =================
  Future<Either<Failure, List<FoodItemEntity>>> getAllFoodItems();

  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByUser(String userId);

  Future<Either<Failure, List<FoodItemEntity>>> getFoodItemsByType(FoodItemType type);

  Future<Either<Failure, FoodItemEntity>> getFoodItemById(String foodItemId);

  /// ================= CREATE / UPDATE / DELETE =================
  Future<Either<Failure, bool>> createFoodItem(FoodItemEntity foodItem);

  Future<Either<Failure, bool>> updateFoodItem(FoodItemEntity foodItem);

  Future<Either<Failure, bool>> deleteFoodItem(String foodItemId);

  /// ================= MEDIA UPLOAD =================
  Future<Either<Failure, String>> uploadFoodPhoto(File photo);
  Future<Either<Failure, String>> uploadFoodVideo(File video);
}
