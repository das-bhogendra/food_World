import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/features/auth/data/datasources/auth_datasource.dart';

import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';


/// ================= PROVIDER =================
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

/// ================= DATASOURCE =================
class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  /// ================= GET CURRENT USER =================
  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final currentUserId = _hiveService.currentUserId;
      if (currentUserId == null) return null;
      return _hiveService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// ================= CHECK EMAIL EXISTS =================
  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return await _hiveService.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }

  /// ================= LOGIN =================
  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null) {
        _hiveService.currentUserId = user.authId; // track logged in user
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  /// ================= LOGOUT =================
  @override
  Future<bool> logout() async {
    try {
      final currentUserId = _hiveService.currentUserId;
      if (currentUserId == null) return false;
      await _hiveService.logoutUser();
      _hiveService.currentUserId = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ================= REGISTER =================
  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }
}
