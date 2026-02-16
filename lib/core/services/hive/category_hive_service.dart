import 'package:hive_flutter/hive_flutter.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';
import 'package:food_mandu/features/category/data/models/category_hive_model.dart';

class CategoryHiveService {
  late Box<CategoryHiveModel> _categoryBox;

  /// Initialize Hive box for categories
  Future<void> init() async {
    // Register Hive adapter for CategoryHiveModel
    if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTypeId)) {
      Hive.registerAdapter(CategoryHiveModelAdapter());
    }

    // Open the box
    _categoryBox = await Hive.openBox<CategoryHiveModel>(
      HiveTableConstant.categoryTable,
    );
  }

  /// Create / Add a category
  Future<bool> createCategory(CategoryHiveModel category) async {
    try {
      await _categoryBox.put(category.id, category);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory(CategoryHiveModel category) async {
    try {
      if (_categoryBox.containsKey(category.id)) {
        await _categoryBox.put(category.id, category);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      if (_categoryBox.containsKey(id)) {
        await _categoryBox.delete(id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all categories
  List<CategoryHiveModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  /// Get a category by ID
  CategoryHiveModel? getCategoryById(String id) {
    return _categoryBox.get(id);
  }

  /// Get all categories added by a specific user
  List<CategoryHiveModel> getCategoriesByUser(String userId) {
    return _categoryBox.values.where((cat) => cat.addedBy == userId).toList();
  }

  /// Close the box
  Future<void> close() async {
    await _categoryBox.close();
  }
}
