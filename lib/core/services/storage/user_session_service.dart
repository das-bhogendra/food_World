import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ================= PROVIDERS =================

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be overridden in main.dart');
});

// User session service provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

/// ================= USER SESSION SERVICE =================
class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthId = 'auth_id';
  static const String _keyFullName = 'full_name';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyRole = 'role';
  static const String _keyProfilePicture = 'profile_picture';
  static const String _keyCreatedAt = 'created_at';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save user session after login
  Future<void> saveUserSession({
    required String authId,
    required String fullName,
    required String username,
    required String email,
    required String role,
    String? phoneNumber,
    String? profilePicture,
    DateTime? createdAt,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyAuthId, authId);
    await _prefs.setString(_keyFullName, fullName);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyRole, role);

    if (phoneNumber != null) {
      await _prefs.setString(_keyPhoneNumber, phoneNumber);
    }
    if (profilePicture != null) {
      await _prefs.setString(_keyProfilePicture, profilePicture);
    }
    if (createdAt != null) {
      await _prefs.setString(_keyCreatedAt, createdAt.toIso8601String());
    }
  }

  /// 🔥 NEW: Update only profile picture (used after upload)
  Future<void> updateProfilePicture(String profilePicture) async {
    await _prefs.setString(_keyProfilePicture, profilePicture);
  }

  /// Clear user session (logout)
  Future<void> clearUserSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyAuthId);
    await _prefs.remove(_keyFullName);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyPhoneNumber);
    await _prefs.remove(_keyProfilePicture);
    await _prefs.remove(_keyCreatedAt);
  }

  /// Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  /// Get stored user data
  String? get authId => _prefs.getString(_keyAuthId);
  String? get fullName => _prefs.getString(_keyFullName);
  String? get username => _prefs.getString(_keyUsername);
  String? get email => _prefs.getString(_keyEmail);
  String? get role => _prefs.getString(_keyRole);
  String? get phoneNumber => _prefs.getString(_keyPhoneNumber);
  String? get profilePicture => _prefs.getString(_keyProfilePicture);
  DateTime? get createdAt {
    final dateStr = _prefs.getString(_keyCreatedAt);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  /// ================= NEW METHOD =================
  /// Returns the current user's ID (authId)
  String getCurrentUserId() {
    final id = _prefs.getString(_keyAuthId);
    if (id == null) {
      throw Exception('No user logged in');
    }
    return id;
  }
}
