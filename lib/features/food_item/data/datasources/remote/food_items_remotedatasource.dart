import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';

import '../food_items_datasource.dart';
import '../../models/food_items_api_model.dart';

final foodItemsRemoteDatasourceProvider =
    Provider<IFoodItemsRemoteDataSource>((ref) {
  return FoodItemsRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class FoodItemsRemoteDataSource implements IFoodItemsRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  FoodItemsRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  // ---------------- CREATE ----------------
  @override
  Future<FoodItemApiModel> createFoodItem(
    FoodItemApiModel item, {
    File? imageFile,
  }) async {
    try {
      final token = await _tokenService.getToken();

      final formData = FormData.fromMap({
        "name": item.name,
        "description": item.description,
        "type": item.type, // must be string: veg / nonVeg
        "price": item.price,
        "isAvailable": item.isAvailable,
        "isBestSeller": item.isBestSeller,
        "isDiscounted": item.isDiscounted,

        if (imageFile != null)
          "foodPhoto": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.createFoodItem,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return FoodItemApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- UPDATE ----------------
  @override
  Future<FoodItemApiModel> updateFoodItem(
    FoodItemApiModel item, {
    File? imageFile,
  }) async {
    try {
      final token = await _tokenService.getToken();

      final formData = FormData.fromMap({
        "name": item.name,
        "description": item.description,
        "type": item.type, // must be string
        "price": item.price,
        "isAvailable": item.isAvailable,
        "isBestSeller": item.isBestSeller,
        "isDiscounted": item.isDiscounted,

        if (imageFile != null)
          "foodPhoto": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _apiClient.put(
        ApiEndpoints.updateFoodItem(item.id),
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return FoodItemApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- DELETE ----------------
  @override
  Future<bool> deleteFoodItem(String id) async {
    try {
      final token = await _tokenService.getToken();

      await _apiClient.delete(
        ApiEndpoints.deleteFoodItem(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- GET ALL ----------------
  @override
  Future<List<FoodItemApiModel>> getAllFoodItems() async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        ApiEndpoints.getAllFoodItems,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return [];

      return (data as List)
          .map((e) => FoodItemApiModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- GET BY ID ----------------
  @override
  Future<FoodItemApiModel?> getFoodItemById(String id) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        '${ApiEndpoints.getFoodItemById}/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return null;

      return FoodItemApiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- GET BY USER ----------------
  @override
  Future<List<FoodItemApiModel>> getFoodItemsByUser(String userId) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        '${ApiEndpoints.getFoodItemsByUser}/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return [];

      return (data as List)
          .map((e) => FoodItemApiModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- GET BY TYPE ----------------
  @override
  Future<List<FoodItemApiModel>> getFoodItemsByType(String type) async {
    try {
      final token = await _tokenService.getToken();

      final response = await _apiClient.get(
        '${ApiEndpoints.getFoodItemsByType}/$type',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return [];

      return (data as List)
          .map((e) => FoodItemApiModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- MEDIA ----------------
  @override
  Future<String> uploadPhoto(File photo) async {
    try {
      final fileName = photo.path.split('/').last;

      final formData = FormData.fromMap({
        'foodPhoto': await MultipartFile.fromFile(
          photo.path,
          filename: fileName,
        ),
      });

      final token = await _tokenService.getToken();

      final response = await _apiClient.uploadFile(
        ApiEndpoints.foodUploadPhoto,
        formData: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data['data'] as String;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadVideo(File video) async {
    try {
      final fileName = video.path.split('/').last;

      final formData = FormData.fromMap({
        'foodVideo': await MultipartFile.fromFile(
          video.path,
          filename: fileName,
        ),
      });

      final token = await _tokenService.getToken();

      final response = await _apiClient.uploadFile(
        ApiEndpoints.foodUploadVideo,
        formData: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data['data'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
