import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/services/hive/food_items_hive_service.dart';
import 'package:food_mandu/features/food_item/data/datasources/food_items_datasource.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_hive_model.dart';

/// ================= PROVIDER =================
final foodItemLocalDatasourceProvider =
    Provider<FoodItemLocalDatasource>((ref) {
  // Use the hive service variable properly
  final hiveService = FoodItemHiveService();
  return FoodItemLocalDatasource(hiveService: hiveService);
});

/// ================= DATASOURCE =================
class FoodItemLocalDatasource implements IFoodItemsLocalDatasource {
  final FoodItemHiveService _hiveService;

  FoodItemLocalDatasource({required FoodItemHiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> createFoodItem(FoodItemHiveModel item) async {
    try {
      await _hiveService.createFoodItem(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateFoodItem(FoodItemHiveModel item) async {
    try {
      await _hiveService.updateFoodItem(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteFoodItem(String foodItemId) async {
    try {
      await _hiveService.deleteFoodItem(foodItemId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<FoodItemHiveModel>> getAllFoodItems() async {
    try {
      return _hiveService.getAllFoodItems();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FoodItemHiveModel?> getFoodItemById(String foodItemId) async {
    try {
      return _hiveService.getFoodItemById(foodItemId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FoodItemHiveModel>> getFoodItemsByUser(String userId) async {
    try {
      return _hiveService.getFoodItemsByUser(userId);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<FoodItemHiveModel>> getFoodItemsByType(String type) async {
    try {
      return _hiveService.getFoodItemsByType(type);
    } catch (_) {
      return [];
    }
  }
}
