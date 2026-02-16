
import '../models/category_api_model.dart';
import '../models/category_hive_model.dart';

abstract interface class ICategoryLocalDatasource {
  Future<bool> createCategory(CategoryHiveModel category);
  Future<bool> updateCategory(CategoryHiveModel category);
  Future<bool> deleteCategory(String categoryId);

  Future<List<CategoryHiveModel>> getAllCategories();
  Future<CategoryHiveModel?> getCategoryById(String categoryId);
  Future<List<CategoryHiveModel>> getCategoriesByUser(String userId);
}

abstract interface class ICategoryRemoteDatasource {
  Future<CategoryApiModel> createCategory(CategoryApiModel category);
  Future<CategoryApiModel> updateCategory(CategoryApiModel category);
  Future<bool> deleteCategory(String id);

  Future<List<CategoryApiModel>> getAllCategories();
  Future<CategoryApiModel?> getCategoryById(String id);
  Future<List<CategoryApiModel>> getCategoriesByUser(String userId);
}
