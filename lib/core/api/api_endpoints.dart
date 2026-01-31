import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // ================= BASE =================
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://10.0.2.2:5005/api'; // Android Emulator
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ================= AUTH / USER =================
  static const String users = '/users';
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static String userById(String id) => '/users/$id';

  // 🔥 PROFILE PHOTO UPLOAD (JWT-based) → CORRECTED
  static const String userUploadPhoto = '/auth/profile'; // matches backend PUT /profile

  // ================= FOOD / ITEMS =================
  static const String foods = '/foods';

  /// CRUD
  static const String createFoodItem = '/foods';
  static String updateFoodItem(String id) => '/foods/$id';
  static String deleteFoodItem(String id) => '/foods/$id';
  static const String getAllFoodItems = '/foods';
  static String getFoodItemById(String id) => '/foods/$id';

  /// Filters
  static String getFoodItemsByUser(String userId) => '/foods/user/$userId';
  static String getFoodItemsByType(String type) => '/foods/type/$type';
  static String foodByCategory(String categoryId) => '/foods/category/$categoryId';

  /// Media upload
  static const String foodUploadPhoto = '/foods/upload/photo';
  static const String foodUploadVideo = '/foods/upload/video';

  // ================= CATEGORY =================
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ================= ORDER =================
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
}
