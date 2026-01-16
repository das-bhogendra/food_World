import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage/storage_service.dart';
import '../services/hive/hive_service.dart';

// ====================== SHARED PREFERENCES PROVIDER ======================

/// Must be overridden in main.dart before runApp()
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});

// ====================== HIVE SERVICE PROVIDER ======================

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('hiveServiceProvider must be overridden');
});
