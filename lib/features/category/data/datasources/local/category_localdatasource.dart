import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/services/hive/category_hive_service.dart';

import '../category_datasource.dart';
import '../../models/category_hive_model.dart';

final categoryLocalDatasourceProvider =
    Provider<ICategoryLocalDatasource>((ref) {
  final hiveService = CategoryHiveService();
  return CategoryLocalDatasource(hiveService: hiveService);
});

class CategoryLocalDatasource implements ICategoryLocalDatasource {
  final CategoryHiveService _hiveService;

  CategoryLocalDatasource({required CategoryHiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> createCategory(CategoryHiveModel category) async {
    try {
      await _hiveService.createCategory(category);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateCategory(CategoryHiveModel category) async {
    try {
      await _hiveService.updateCategory(category);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _hiveService.deleteCategory(categoryId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<CategoryHiveModel>> getAllCategories() async {
    try {
      return _hiveService.getAllCategories();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CategoryHiveModel?> getCategoryById(String categoryId) async {
    try {
      return _hiveService.getCategoryById(categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CategoryHiveModel>> getCategoriesByUser(String userId) async {
    try {
      return _hiveService.getCategoriesByUser(userId);
    } catch (_) {
      return [];
    }
  }
}
