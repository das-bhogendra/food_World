import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/features/auth/data/datasources/auth_datasource.dart';
import 'package:food_mandu/features/auth/data/models/auth_api_model.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';

// Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(ApiEndpoints.login, data: {
      "email": email,
      "password": password,
    });

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

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

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(ApiEndpoints.register, data: user.toJson());

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);

      // Save session after registration
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

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(authId));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    return null;
  }
}
