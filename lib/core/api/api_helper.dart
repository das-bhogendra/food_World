import 'api_endpoints.dart';

class ApiHelper {
  /// Converts relative path to full URL
  static String fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiEndpoints.baseUrl}$path';
  }
}
