import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/screen/bottom_screen/home_screen.dart';
import 'package:dartz/dartz.dart';

class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

void main() {
  late ProviderContainer container;
  late MockFoodItemsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockRepository = MockFoodItemsRepository();

    // Default mock behavior - return empty list
    when(() => mockRepository.getAllFoodItems()).thenAnswer(
      (_) async => const Right([]),
    );

    container = ProviderContainer(
      overrides: [
        foodItemsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget({required String userRole, required String userId}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: HomeScreen(userRole: userRole, userId: userId),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('should show CircularProgressIndicator when loading',
        (tester) async {
      // Set state to loading
      final notifier = container.read(foodItemNotifierProvider.notifier);
      notifier.state = const FoodItemsState(
        status: FoodItemStatus.loading,
        items: [],
      );

      await tester.pumpWidget(createTestWidget(userRole: 'user', userId: 'u1'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when status is error',
        (tester) async {
      // Set state to error
      final notifier = container.read(foodItemNotifierProvider.notifier);
      notifier.state = const FoodItemsState(
        status: FoodItemStatus.error,
        errorMessage: "Network Error",
        items: [],
      );

      await tester.pumpWidget(createTestWidget(userRole: 'user', userId: 'u1'));

      expect(find.text("Network Error"), findsOneWidget);
    });

    testWidgets('should display food items sections', (tester) async {
      final foodItem = FoodItemEntity(
        id: 'f1',
        name: 'Pizza',
        price: 250,
        isBestSeller: true,
        isDiscounted: false,
        type: FoodItemType.nonVeg,
        addedBy: 'user1',
        imageUrl: '',
      );

      // Set state with food items
      final notifier = container.read(foodItemNotifierProvider.notifier);
      notifier.state = FoodItemsState(
        status: FoodItemStatus.loaded,
        items: [foodItem],
        vegItems: [],
        nonVegItems: [foodItem],
        drinkItems: [],
        dessertItems: [],
      );

      await tester.pumpWidget(createTestWidget(userRole: 'user', userId: 'u1'));
      await tester.pumpAndSettle();

      expect(find.text('Best Sellers'), findsOneWidget);
      expect(find.text('Non-Veg'), findsOneWidget);
      expect(find.text('Pizza'),
          findsNWidgets(2)); // in both Best Sellers and Non-Veg
      expect(find.text('₹250.00'), findsNWidgets(2));
      expect(find.text('Add to Cart'), findsNWidgets(2));
    });

    testWidgets('should display cart badge when items are present',
        (tester) async {
      final foodItem = FoodItemEntity(
        id: 'f1',
        name: 'Pizza',
        price: 250,
        isBestSeller: true,
        isDiscounted: false,
        type: FoodItemType.nonVeg,
        addedBy: 'user1',
        imageUrl: '',
      );

      // Set food items state
      final foodNotifier = container.read(foodItemNotifierProvider.notifier);
      foodNotifier.state = FoodItemsState(
        status: FoodItemStatus.loaded,
        items: [foodItem],
        vegItems: [],
        nonVegItems: [foodItem],
        drinkItems: [],
        dessertItems: [],
      );

      // Set cart state with item
      final cartNotifier = container.read(cartProvider.notifier);
      cartNotifier.state = CartState(
        items: [
          CartItem(
            foodItem: foodItem,
            quantity: 1,
          )
        ],
      );

      await tester.pumpWidget(createTestWidget(userRole: 'user', userId: 'u1'));
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // cart badge count
    });
  });
}
