import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://10.0.2.2:3000/api'; // For Android Emulator
    }
  }
  // For iOS Simulator: 'http://localhost:3000/api'
  // For Physical Device: 'http://192.168.x.x:3000/api'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth / User Endpoints ============
  static const String users = '/users';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static String userById(String id) => '/users/$id';
  static String userProfilePicture(String id) => '/users/$id/photo';

  // ============ Food / Item Endpoints ============
  static const String foods = '/foods';
  static String foodById(String id) => '/foods/$id';
  static String foodByCategory(String categoryId) => '/foods/category/$categoryId';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Order Endpoints ============
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
}
