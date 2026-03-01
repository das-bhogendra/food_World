import 'package:hive_flutter/hive_flutter.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';
import 'package:food_mandu/features/order/data/models/order_hive_model.dart';

class HiveService {
  static const String _currentUserKey = 'current_user_id';

  late Box<AuthHiveModel> _authBox;
  late Box<String> _sessionBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AuthHiveModelAdapter());

    // Register Order adapters
    Hive.registerAdapter(OrderItemHiveModelAdapter());
    Hive.registerAdapter(OrderHiveModelAdapter());

    // Open boxes
    _authBox = await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    _sessionBox = await Hive.openBox<String>('session');
  }

  // ------------------------------
  // Current user ID management
  // ------------------------------
  String? get currentUserId => _sessionBox.get(_currentUserKey);

  set currentUserId(String? id) {
    if (id == null) {
      _sessionBox.delete(_currentUserKey);
    } else {
      _sessionBox.put(_currentUserKey, id);
    }
  }

  // ------------------------------
  // User management methods
  // ------------------------------
  Future<AuthHiveModel?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return _authBox.get(userId);
  }

  Future<bool> isEmailExists(String email) async {
    final users = _authBox.values;
    return users.any((user) => user.email == email);
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values;
    try {
      return users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> logoutUser() async {
    currentUserId = null;
  }

  Future<void> registerUser(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
  }

  // ------------------------------
  // Global clear all data (for shake logout)
  // ------------------------------
  Future<void> clearAllData() async {
    await _authBox.clear();
    await _sessionBox.clear();
  }

  // ------------------------------
  // Close boxes
  // ------------------------------
  Future<void> close() async {
    await _authBox.close();
    await _sessionBox.close();
  }
}