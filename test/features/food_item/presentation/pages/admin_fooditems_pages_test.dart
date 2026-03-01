import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/pages/admin_fooditems_pages.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

// ================= MOCK REPOSITORY =================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

// ================= FALLBACK VALUES =================
class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

// ================= WIDGET TEST =================
void main() {
  late ProviderContainer container;
  late MockFoodItemsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockRepository = MockFoodItemsRepository();
  });

  tearDown(() => container.dispose());

  testWidgets('should show available and sold out items', (tester) async {
    final food1 = FoodItemEntity(
      id: '1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      price: 10.0,
      isAvailable: true,
      imageUrl: '',
      description: 'Delicious pizza',
    );
    final food2 = FoodItemEntity(
      id: '2',
      name: 'Pasta',
      addedBy: 'Admin',
      type: FoodItemType.nonVeg,
      price: 12.0,
      isAvailable: false,
      imageUrl: '',
      description: 'Creamy pasta',
    );

    // Mock repository to return loaded data
    when(() => mockRepository.getAllFoodItems()).thenAnswer(
        (_) async => Right<Failure, List<FoodItemEntity>>([food1, food2]));

    when(() => mockRepository.deleteFoodItem(any()))
        .thenAnswer((_) async => const Right<Failure, bool>(true));

    container = ProviderContainer(
      overrides: [
        foodItemsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminFoodItemsPage()),
      ),
    );

    // Wait for async fetch to complete - use multiple pumps
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Check tabs titles
    expect(find.text('Available (1)'), findsOneWidget);
    expect(find.text('Sold Out (1)'), findsOneWidget);

    // Check food item in first tab (Available)
    expect(find.text('Pizza'), findsOneWidget);
  });

  testWidgets('should delete item when delete button is tapped',
      (tester) async {
    final food1 = FoodItemEntity(
      id: '1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      price: 10.0,
      isAvailable: true,
      imageUrl: '',
      description: 'Delicious pizza',
    );

    // Mock repository to return loaded data immediately
    when(() => mockRepository.getAllFoodItems())
        .thenAnswer((_) async => Right<Failure, List<FoodItemEntity>>([food1]));

    when(() => mockRepository.deleteFoodItem(any()))
        .thenAnswer((_) async => const Right<Failure, bool>(true));

    container = ProviderContainer(
      overrides: [
        foodItemsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminFoodItemsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Pizza'), findsOneWidget);

    // Tap delete
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Delete Food Item'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this food item?'),
        findsOneWidget);

    // Confirm delete
    await tester.tap(find.text('Delete'));
    await tester.pump();

    // Verify delete was called
    verify(() => mockRepository.deleteFoodItem('1')).called(1);
  });
}
