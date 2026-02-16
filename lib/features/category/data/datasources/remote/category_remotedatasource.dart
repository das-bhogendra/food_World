import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';

import '../category_datasource.dart';
import '../../models/category_api_model.dart';

final categoryRemoteDatasourceProvider =
    Provider<ICategoryRemoteDatasource>((ref) {
  return CategoryRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class CategoryRemoteDatasource implements ICategoryRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  CategoryRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  // ---------------- CRUD ----------------

  @override
  Future<CategoryApiModel> createCategory(CategoryApiModel category) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.post(
        ApiEndpoints.createCategory,
        data: category.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return CategoryApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CategoryApiModel> updateCategory(CategoryApiModel category) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.put(
        ApiEndpoints.updateCategory(category.id),
        data: category.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return CategoryApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteCategory(String id) async {
    try {
      final token = await _tokenService.getToken();

      await _apiClient.delete(
        ApiEndpoints.deleteCategory(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        ApiEndpoints.getAllCategories,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];

      if (data == null) return [];

      return (data as List)
          .map((e) => CategoryApiModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CategoryApiModel?> getCategoryById(String id) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        ApiEndpoints.getcategoryById(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return null;

      return CategoryApiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryApiModel>> getCategoriesByUser(String userId) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        ApiEndpoints.getCategoriesByUser(userId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];

      if (data == null) return [];

      return (data as List)
          .map((e) => CategoryApiModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
