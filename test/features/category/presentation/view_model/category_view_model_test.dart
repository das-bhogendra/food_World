import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/features/category/domain/entities/category_entity.dart';
import 'package:food_mandu/features/category/presentation/view_model/category_view_model.dart';
import 'package:food_mandu/features/category/presentation/state/category_state.dart';

class MockDio extends Mock implements Dio {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late ProviderContainer container;
  late MockDio mockDio;
  late MockTokenService mockTokenService;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() async {
    mockDio = MockDio();
    mockTokenService = MockTokenService();

    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    container.dispose();
  });

  const tCategory = CategoryEntity(
      id: '1', name: 'Test', description: 'Desc', createdBy: 'admin');
  const tToken = 'dummy_token';

  group('CategoryViewModel - loadCategories', () {
    test('should load categories successfully', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              "data": [
                {
                  "id": "1",
                  "name": "Test",
                  "description": "Desc",
                  "createdBy": "admin"
                }
              ]
            },
            statusCode: 200,
          ));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container.read(categoryViewModelProvider.notifier).loadCategories();

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.loaded);
      expect(state.categories.length, 1);
      expect(state.categories.first.name, 'Test');
    });

    test('should handle error when load fails', () async {
      when(() => mockDio.get(any())).thenThrow(Exception('Network error'));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container.read(categoryViewModelProvider.notifier).loadCategories();

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.error);
      expect(state.errorMessage, contains('Network error'));
    });
  });

  group('CategoryViewModel - createCategory', () {
    test('should create category successfully', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.post(any(),
              data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  "data": {
                    "id": "1",
                    "name": "Test",
                    "description": "Desc",
                    "createdBy": "admin"
                  }
                },
                statusCode: 200,
              ));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container.read(categoryViewModelProvider.notifier).createCategory(
            name: 'Test',
            description: 'Desc',
            createdBy: 'admin',
          );

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.created);
      expect(state.categories.length, 1);
      expect(state.categories.first.name, 'Test');
    });

    test('should handle error when creation fails', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.post(any(),
              data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(Exception('Create failed'));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container.read(categoryViewModelProvider.notifier).createCategory(
            name: 'Test',
            description: 'Desc',
            createdBy: 'admin',
          );

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.error);
      expect(state.errorMessage, contains('Create failed'));
    });
  });

  group('CategoryViewModel - updateCategory', () {
    test('should update category successfully', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.put(any(),
              data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  "data": {
                    "id": "1",
                    "name": "Updated",
                    "description": "Desc",
                    "createdBy": "admin"
                  }
                },
                statusCode: 200,
              ));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      // Set initial state with category
      container.read(categoryViewModelProvider.notifier).state =
          const CategoryState(categories: [tCategory]);

      await container
          .read(categoryViewModelProvider.notifier)
          .updateCategory(tCategory);

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.updated);
      expect(state.categories.first.name, 'Updated');
    });

    test('should handle error when update fails', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.put(any(),
              data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(Exception('Update failed'));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container
          .read(categoryViewModelProvider.notifier)
          .updateCategory(tCategory);

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.error);
      expect(state.errorMessage, contains('Update failed'));
    });
  });

  group('CategoryViewModel - deleteCategory', () {
    test('should delete category successfully', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.delete(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      // Set initial state with category
      container.read(categoryViewModelProvider.notifier).state =
          const CategoryState(categories: [tCategory]);

      await container
          .read(categoryViewModelProvider.notifier)
          .deleteCategory('1');

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.deleted);
      expect(state.categories, isEmpty);
    });

    test('should handle error when deletion fails', () async {
      when(() => mockTokenService.getToken()).thenAnswer((_) async => tToken);
      when(() => mockDio.delete(any(), options: any(named: 'options')))
          .thenThrow(Exception('Delete failed'));

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenServiceProvider.overrideWithValue(mockTokenService),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      await container
          .read(categoryViewModelProvider.notifier)
          .deleteCategory('1');

      final state = container.read(categoryViewModelProvider);
      expect(state.status, CategoryStatus.error);
      expect(state.errorMessage, contains('Delete failed'));
    });
  });
}
