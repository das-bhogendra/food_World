import 'dart:io';

import '../models/food_items_hive_model.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_api_model.dart';
abstract interface class IFoodItemsLocalDatasource {
  Future<bool> createFoodItem(FoodItemHiveModel item);
  Future<bool> updateFoodItem(FoodItemHiveModel item);
  Future<bool> deleteFoodItem(String foodItemId);

  Future<List<FoodItemHiveModel>> getAllFoodItems();
  Future<FoodItemHiveModel?> getFoodItemById(String foodItemId);
  Future<List<FoodItemHiveModel>> getFoodItemsByUser(String userId);
  Future<List<FoodItemHiveModel>> getFoodItemsByType(String type);
}

abstract interface class IFoodItemsRemoteDataSource {
  
  Future<FoodItemApiModel> createFoodItem(FoodItemApiModel item);
  Future<FoodItemApiModel> updateFoodItem(FoodItemApiModel item);
  Future<bool> deleteFoodItem(String id);
  Future<List<FoodItemApiModel>> getAllFoodItems();
  Future<FoodItemApiModel?> getFoodItemById(String id);
  Future<List<FoodItemApiModel>> getFoodItemsByUser(String userId);
  Future<List<FoodItemApiModel>> getFoodItemsByType(String type);

  /// Media upload
  Future<String> uploadPhoto(File photo);
  Future<String> uploadVideo(File video);
}