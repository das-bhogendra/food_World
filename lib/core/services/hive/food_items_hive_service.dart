import 'package:hive_flutter/hive_flutter.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';
import 'package:food_mandu/features/food_item/data/models/food_items_hive_model.dart';

class FoodItemHiveService {
  late Box<FoodItemHiveModel> _foodBox;

  /// Initialize Hive box for food items
  Future<void> init() async {
    // Register Hive adapter for FoodItemHiveModel
    if (!Hive.isAdapterRegistered(HiveTableConstant.foodItemTypeId)) {
      Hive.registerAdapter(FoodItemHiveModelAdapter());
    }

    // Open the box
    _foodBox = await Hive.openBox<FoodItemHiveModel>(
      HiveTableConstant.foodItemTable,
    );
  }

  /// Create / Add a food item
  Future<bool> createFoodItem(FoodItemHiveModel item) async {
    try {
      await _foodBox.put(item.id, item);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing food item
  Future<bool> updateFoodItem(FoodItemHiveModel item) async {
    try {
      if (_foodBox.containsKey(item.id)) {
        await _foodBox.put(item.id, item);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete a food item
  Future<bool> deleteFoodItem(String id) async {
    try {
      if (_foodBox.containsKey(id)) {
        await _foodBox.delete(id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all food items
  List<FoodItemHiveModel> getAllFoodItems() {
    return _foodBox.values.toList();
  }

  /// Get a food item by ID
  FoodItemHiveModel? getFoodItemById(String id) {
    return _foodBox.get(id);
  }

  /// Get all food items added by a specific user
  List<FoodItemHiveModel> getFoodItemsByUser(String userId) {
    return _foodBox.values.where((item) => item.addedBy == userId).toList();
  }

  /// Get all food items of a specific type
  List<FoodItemHiveModel> getFoodItemsByType(String type) {
    return _foodBox.values.where((item) => item.type == type).toList();
  }

  /// Close the box
  Future<void> close() async {
    await _foodBox.close();
  }
}
