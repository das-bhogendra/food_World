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

class FoodItemsRemoteDataSource
    implements IFoodItemsRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  FoodItemsRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  // ---------------- CRUD ----------------

  @override
  Future<FoodItemApiModel> createFoodItem(
      FoodItemApiModel item) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.createFoodItem,
      data: item.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return FoodItemApiModel.fromJson(response.data['data']);
  }

  @override
  Future<FoodItemApiModel> updateFoodItem(
      FoodItemApiModel item) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.put(
      '${ApiEndpoints.updateFoodItem}/${item.id}',
      data: item.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return FoodItemApiModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> deleteFoodItem(String id) async {
    final token = await _tokenService.getToken();

    await _apiClient.delete(
      '${ApiEndpoints.deleteFoodItem}/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return true;
  }

  @override
  Future<List<FoodItemApiModel>> getAllFoodItems() async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.getAllFoodItems,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data['data'] as List)
        .map((e) => FoodItemApiModel.fromJson(e))
        .toList();
  }

  @override
  Future<FoodItemApiModel?> getFoodItemById(String id) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      '${ApiEndpoints.getFoodItemById}/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return FoodItemApiModel.fromJson(response.data['data']);
  }

  @override
  Future<List<FoodItemApiModel>> getFoodItemsByUser(
      String userId) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      '${ApiEndpoints.getFoodItemsByUser}/$userId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data['data'] as List)
        .map((e) => FoodItemApiModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<FoodItemApiModel>> getFoodItemsByType(
      String type) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      '${ApiEndpoints.getFoodItemsByType}/$type',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data['data'] as List)
        .map((e) => FoodItemApiModel.fromJson(e))
        .toList();
  }

  // ---------------- MEDIA ----------------

  @override
  Future<String> uploadPhoto(File photo) async {
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
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return response.data['data'] as String;
  }

  @override
  Future<String> uploadVideo(File video) async {
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
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return response.data['data'] as String;
  }
}
