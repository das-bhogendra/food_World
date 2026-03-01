import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._(); // Private constructor to prevent instantiation

  // ================= BASE =================
  static const bool isPhysicalDevice = true;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://10.151.153.202:5005/api/';
    }

    if (Platform.isAndroid) {
      if (isPhysicalDevice) {
        // Physical device
        return 'http://172.26.0.20:5005/api/';
      } else {
        // Android emulator
        return 'http://10.0.2.2:5005/api/';
      }
    }

    // iOS Simulator
    return 'http://localhost:5005/api/';
  }

  // For logging/debugging

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ================= AUTH / USER =================
  static const String users = '/users';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static String userById(String id) => '/users/$id';
  static const String userUploadPhoto = '/auth/profile'; // PUT /profile

  // ================= FOOD / ITEMS =================
  static const String foods = '/fooditems';

  /// CRUD
  static const String createFoodItem = '/fooditems';
  static String updateFoodItem(String id) => '/fooditems/$id';
  static String deleteFoodItem(String id) => '/fooditems/$id';
  static const String getAllFoodItems = '/fooditems';
  static String getFoodItemById(String id) => '/fooditems/$id';

  /// Filters
  static String getFoodItemsByUser(String userId) => '/fooditems/user/$userId';
  static String getFoodItemsByType(String type) => '/fooditems/type/$type';
  static String foodByCategory(String categoryId) =>
      '/fooditems/category/$categoryId';

  /// Media upload
  static const String foodUploadPhoto = '/fooditems/upload/photo';
  static const String foodUploadVideo = '/fooditems/upload/video';

  // ================= CATEGORY =================
  static const String categories = '/categories';

  /// CRUD
  static const String createCategory = '/categories';
  static String updateCategory(String id) => '/categories/$id';
  static String deleteCategory(String id) => '/categories/$id';
  static const String getAllCategories = '/categories';
  static String getcategoryById(String id) => '/categories/$id';

  /// Get categories added by a specific user
  static String getCategoriesByUser(String userId) =>
      '/categories/user/$userId';

  // ================= ORDER =================
  static const String orders = '/orders';

  /// CRUD
  static const String createOrder = '/orders';
  static String updateOrder(String id) => '/orders/$id';
  static String deleteOrder(String id) => '/orders/$id';
  static const String getAllOrders = '/orders';
  static String getOrderById(String id) => '/orders/$id';

  /// Filters
  static String getOrdersByUser(String userId) => '/orders?userId=$userId';
  static String getOrdersByStatus(String status) => '/orders/status/$status';

  /// Update status
  static String updateOrderStatus(String id) => '/orders/$id/status';
}
