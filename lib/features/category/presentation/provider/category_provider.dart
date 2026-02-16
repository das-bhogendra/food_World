import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/category/domain/entities/category_entity.dart';
import 'package:food_mandu/features/category/domain/repositories/category_repository.dart';

/// ================= CATEGORY REPOSITORY PROVIDER =================
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  throw UnimplementedError(
      'Category repository not initialized. Provide your CategoryRepositoryImpl here.');
});

/// ================= FETCH ALL CATEGORIES =================
final getAllCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.getAllCategories();
  return result.fold(
    (failure) {
      print("Failed to fetch categories: ${failure.message}");
      return []; // fallback to empty list
    },
    (categories) => categories,
  );
});

/// ================= FETCH CATEGORY BY ID =================
final getCategoryByIdProvider =
    FutureProvider.family<CategoryEntity?, String>((ref, categoryId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.getCategoryById(categoryId);
  return result.fold(
    (failure) {
      print("Failed to fetch category by ID: ${failure.message}");
      return null;
    },
    (category) => category,
  );
});

/// ================= FETCH CATEGORIES BY USER =================
final getCategoriesByUserProvider =
    FutureProvider.family<List<CategoryEntity>, String>((ref, userId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.getCategoriesByUser(userId);
  return result.fold(
    (failure) {
      print("Failed to fetch categories by user: ${failure.message}");
      return [];
    },
    (categories) => categories,
  );
});

/// ================= CREATE CATEGORY =================
final createCategoryProvider =
    FutureProvider.family.autoDispose<bool, CategoryEntity>((ref, category) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.createCategory(category);
  return result.fold(
    (failure) {
      print("Failed to create category: ${failure.message}");
      return false;
    },
    (success) => success,
  );
});

/// ================= UPDATE CATEGORY =================
final updateCategoryProvider =
    FutureProvider.family.autoDispose<bool, CategoryEntity>((ref, category) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.updateCategory(category);
  return result.fold(
    (failure) {
      print("Failed to update category: ${failure.message}");
      return false;
    },
    (success) => success,
  );
});

/// ================= DELETE CATEGORY =================
final deleteCategoryProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, categoryId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.deleteCategory(categoryId);
  return result.fold(
    (failure) {
      print("Failed to delete category: ${failure.message}");
      return false;
    },
    (success) => success,
  );
});
