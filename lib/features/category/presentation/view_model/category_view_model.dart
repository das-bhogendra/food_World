import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/storage/token_service.dart';
import '../../domain/entities/category_entity.dart';
import '../state/category_state.dart';

/// Provider for Dio instance - can be overridden in tests
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});

final categoryViewModelProvider =
    NotifierProvider<CategoryViewModel, CategoryState>(
  () => CategoryViewModel(),
);

class CategoryViewModel extends Notifier<CategoryState> {
  late final Dio _dio;
  late final TokenService _tokenService;

  @override
  CategoryState build() {
    _dio = ref.read(dioProvider);
    _tokenService = ref.read(tokenServiceProvider);

    return const CategoryState();
  }

  // ===============================
  // Helper: Auth Header
  // ===============================
  Future<Options> _authOptions() async {
    final token = await _tokenService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: Token missing. Please login again.");
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  // ===============================
  // LOAD ALL CATEGORIES (PUBLIC)
  // ===============================
  Future<void> loadCategories() async {
    state = state.copyWith(status: CategoryStatus.loading);

    try {
      final response = await _dio.get(ApiEndpoints.getAllCategories);

      final data = response.data["data"];

      if (data == null) {
        state = state.copyWith(status: CategoryStatus.loaded, categories: []);
        return;
      }

      final categories =
          (data as List).map((json) => CategoryEntity.fromJson(json)).toList();

      state = state.copyWith(
        status: CategoryStatus.loaded,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===============================
  // CREATE CATEGORY (AUTH REQUIRED)
  // ===============================
  Future<void> createCategory({
    required String name,
    String? description,
    required String createdBy,
  }) async {
    state = state.copyWith(status: CategoryStatus.loading);

    try {
      final response = await _dio.post(
        ApiEndpoints.createCategory,
        data: {
          "name": name,
          "description": description,
          "createdBy": createdBy,
        },
        options: await _authOptions(),
      );

      final newCategory = CategoryEntity.fromJson(response.data["data"]);

      state = state.copyWith(
        status: CategoryStatus.created,
        categories: [...state.categories, newCategory],
      );
    } catch (e) {
      state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===============================
  // UPDATE CATEGORY (AUTH REQUIRED)
  // ===============================
  Future<void> updateCategory(CategoryEntity category) async {
    state = state.copyWith(status: CategoryStatus.loading);

    try {
      final response = await _dio.put(
        ApiEndpoints.updateCategory(category.id),
        data: category.toJson(),
        options: await _authOptions(),
      );

      // backend returns updated object (recommended)
      final updatedCategory = CategoryEntity.fromJson(response.data["data"]);

      final updatedList = state.categories
          .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
          .toList();

      state = state.copyWith(
        status: CategoryStatus.updated,
        categories: updatedList,
      );
    } catch (e) {
      state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===============================
  // DELETE CATEGORY (AUTH REQUIRED)
  // ===============================
  Future<void> deleteCategory(String id) async {
    state = state.copyWith(status: CategoryStatus.loading);

    try {
      await _dio.delete(
        ApiEndpoints.deleteCategory(id),
        options: await _authOptions(),
      );

      final updatedList = state.categories.where((c) => c.id != id).toList();

      state = state.copyWith(
        status: CategoryStatus.deleted,
        categories: updatedList,
      );
    } catch (e) {
      state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
