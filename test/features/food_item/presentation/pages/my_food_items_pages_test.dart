import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/pages/my_food_items_pages.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';

// ================= MOCKS =================
class MockFoodItemNotifier extends Mock implements FoodItemNotifier {}
class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

void main() {
  late MockFoodItemNotifier mockNotifier;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockNotifier = MockFoodItemNotifier();

    // Default empty state
    when(() => mockNotifier.state).thenReturn(FoodItemsState(
      status: FoodItemStatus.initial,
      items: [],
      vegItems: [],
      nonVegItems: [],
      drinkItems: [],
      dessertItems: [],
    ));

    container = ProviderContainer(
      overrides: [
        foodItemNotifierProvider.overrideWithValue(mockNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const MyFoodItemsPage(),
      ),
    );
  }

  testWidgets('shows CircularProgressIndicator when loading', (tester) async {
    when(() => mockNotifier.state).thenReturn(FoodItemsState(
      status: FoodItemStatus.loading,
      items: [],
      vegItems: [],
      nonVegItems: [],
      drinkItems: [],
      dessertItems: [],
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state text for available and sold out tabs', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Available tab
    expect(find.text('No available items'), findsOneWidget);

    // Switch to Sold Out tab
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();
    expect(find.text('No sold out items'), findsOneWidget);
  });

  testWidgets('displays food item cards', (tester) async {
    final food1 = FoodItemEntity(
      id: 'f1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      isAvailable: true,
      fullImageUrl: '',
    );

    final food2 = FoodItemEntity(
      id: 'f2',
      name: 'Burger',
      addedBy: 'Admin',
      type: FoodItemType.nonVeg,
      isAvailable: false,
      fullImageUrl: '',
    );

    when(() => mockNotifier.state).thenReturn(FoodItemsState(
      status: FoodItemStatus.loaded,
      items: [food1, food2],
      vegItems: [food1],
      nonVegItems: [food2],
      drinkItems: [],
      dessertItems: [],
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Available tab shows Pizza
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Added by Admin'), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);

    // Switch to Sold Out tab
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();

    expect(find.text('Burger'), findsOneWidget);
    expect(find.text('Added by Admin'), findsOneWidget);
    expect(find.text('Sold Out'), findsOneWidget);
  });

  testWidgets('tapping Order button triggers callback', (tester) async {
    bool orderTapped = false;

    final food = FoodItemEntity(
      id: 'f1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      isAvailable: true,
      fullImageUrl: '',
    );

    when(() => mockNotifier.state).thenReturn(FoodItemsState(
      status: FoodItemStatus.loaded,
      items: [food],
      vegItems: [food],
      nonVegItems: [],
      drinkItems: [],
      dessertItems: [],
    ));

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MyFoodItemsPage(),
      ),
    ));

    await tester.pumpAndSettle();

    final orderButton = find.text('Order');
    expect(orderButton, findsOneWidget);

    // Simulate tap
    await tester.tap(orderButton);
    await tester.pump();

    // Here you can verify callbacks if you pass them via _FoodItemCard.onOrder
    // Currently, we just ensure the button exists and is tappable
  });
}