import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';
import 'package:food_mandu/features/auth/data/datasources/auth_datasource.dart';
import 'package:food_mandu/features/auth/data/models/auth_api_model.dart';

// Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  // ---------------- LOGIN ----------------
  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      final token = response.data['token'];
      await _tokenService.saveToken(token);

      await _userSessionService.saveUserSession(
        authId: user.id!,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        role: user.role,
        phoneNumber: user.phoneNumber,
        profilePicture: user.profilePicture,
      );

      return user;
    }

    return null;
  }

  // ---------------- REGISTER ----------------
  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);

      final token = response.data['token'];
      await _tokenService.saveToken(token);

      await _userSessionService.saveUserSession(
        authId: registeredUser.id!,
        fullName: registeredUser.fullName,
        username: registeredUser.username,
        email: registeredUser.email,
        role: registeredUser.role,
        phoneNumber: registeredUser.phoneNumber,
        profilePicture: registeredUser.profilePicture,
      );

      return registeredUser;
    }

    return user;
  }

  // ---------------- GET USER ----------------
  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(authId));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    return null;
  }

  // ---------------- UPLOAD PROFILE PHOTO ----------------
  @override
  Future<String> uploadProfilePhoto(File photo) async {
    final fileName = photo.path.split('/').last;

    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
      ),
    });

    final token = await _tokenService.getToken();

    if (token == null) {
      throw Exception('Unauthorized: Token missing');
    }

    final response = await _apiClient.uploadFile(
      ApiEndpoints.userUploadPhoto,
      formData: formData,
      options: Options(
        method: 'PUT',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.data['success'] == true) {
      final imageUrl = response.data['data']['profilePicture'];

      // update local session immediately
      await _userSessionService.updateProfilePicture(imageUrl);

      return imageUrl;
    }

    throw Exception('Profile photo upload failed');
  }
}
