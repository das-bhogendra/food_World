import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';


import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  String? currentUserId; // ✅ track the logged-in user

  /// Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
     print("✅ Hive Initialized at: $path");
     print("✅ Auth box opened: ${Hive.isBoxOpen(HiveTableConstant.authTable)}");
  }

  /// Register Hive Adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  /// Open all required boxes
  Future<void> openBoxes() async {
    
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  /// Close Hive
  Future<void> close() async {
    await Hive.close();
  }

  

  

  /// ================= AUTH BOX =================
  Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  /// Register user
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    print("✅ User Registered:");
    print("ID: ${model.authId}");
    print("Email: ${model.email}");
    return model;
  }

  /// Login user
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      currentUserId = users.first.authId; // ✅ store logged-in user
      print("✅ Login Success");
      print("Current User ID: $currentUserId");
      return users.first;
    }
    return null;
  }

  /// Logout current user
  Future<void> logoutUser() async {
    if (currentUserId != null) {
      await _authBox.delete(currentUserId);
      currentUserId = null;
    }
  }

  AuthHiveModel? getCurrentUser() {
  if (currentUserId == null) {
    print("⚠️ No user logged in");
    return null;
  }

  final user = _authBox.get(currentUserId);
  print("👤 Current User: ${user?.email}");

  return user;
}


  /// Check if email already exists
  Future<bool> isEmailExists(String email) async {
    final exists = _authBox.values.any((user) => user.email == email);
    return exists;
  }
}
