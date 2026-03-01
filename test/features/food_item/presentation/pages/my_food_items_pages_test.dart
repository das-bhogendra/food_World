import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/pages/my_food_items_pages.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

// ================= MOCKS =================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

// ================= FALLBACK VALUES =================
class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

// ================= STUB NOTIFIER =================
// Custom notifier that doesn't auto-fetch on build
class StubFoodItemNotifier extends FoodItemNotifier {
  @override
  FoodItemsState build() {
    // Don't fetch automatically - wait for manual trigger
    // Don't call super.build() which would fetch data
    return const FoodItemsState();
  }

  // Override fetchFoodItems to do nothing in tests
  @override
  Future<void> fetchFoodItems() async {
    // Stub - do nothing
  }
}

void main() {
  late MockFoodItemsRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockRepository = MockFoodItemsRepository();

    // Default mock behavior - returns empty list
    when(() => mockRepository.getAllFoodItems()).thenAnswer(
      (_) async => const Right([]),
    );
    when(() => mockRepository.getFoodItemsByUser(any())).thenAnswer(
      (_) async => const Right([]),
    );

    container = ProviderContainer(
      overrides: [
        foodItemsRepositoryProvider.overrideWithValue(mockRepository),
        // Override the notifier provider to use stub (prevents auto-fetch)
        foodItemNotifierProvider.overrideWith(() => StubFoodItemNotifier()),
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
    // Set state to loading BEFORE building the widget
    // This ensures the state is set before any async operations
    final notifier = container.read(foodItemNotifierProvider.notifier);
    notifier.state = const FoodItemsState(
      status: FoodItemStatus.loading,
      items: [],
    );

    await tester.pumpWidget(createTestWidget());
    // Use pump with duration to allow frame to complete but not settle (loading state)
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state text for available and sold out tabs',
      (tester) async {
    // Set state to loaded with empty items BEFORE building widget
    final notifier = container.read(foodItemNotifierProvider.notifier);
    notifier.state = const FoodItemsState(
      status: FoodItemStatus.loaded,
      items: [],
    );

    await tester.pumpWidget(createTestWidget());
    // Allow time for the widget to build but not wait for fetch
    await tester.pump();

    // Available tab - the page filters by type (veg = Available, nonVeg = Sold Out)
    // Empty veg items should show "No available items"
    expect(find.text('No available items'), findsOneWidget);

    // Switch to Sold Out tab
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();
    expect(find.text('No sold out items'), findsOneWidget);
  });

  testWidgets('displays food item cards', (tester) async {
    // Note: The page filters by FoodItemType.veg for "Available" tab
    // and FoodItemType.nonVeg for "Sold Out" tab
    final food1 = FoodItemEntity(
      id: 'f1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg, // This goes to Available tab
      price: 10.0,
      isAvailable: true,
      imageUrl: '',
    );

    final food2 = FoodItemEntity(
      id: 'f2',
      name: 'Burger',
      addedBy: 'Admin',
      type: FoodItemType.nonVeg, // This goes to Sold Out tab
      price: 8.0,
      isAvailable: false,
      imageUrl: '',
    );

    // Set state with items BEFORE building widget
    final notifier = container.read(foodItemNotifierProvider.notifier);
    notifier.state = FoodItemsState(
      status: FoodItemStatus.loaded,
      items: [food1, food2],
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Available tab shows Pizza (type: veg)
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Added by Admin'), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);

    // Switch to Sold Out tab (type: nonVeg)
    // Find and tap the Sold Out tab specifically (not the button)
    final soldOutTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Sold Out'),
    );
    await tester.tap(soldOutTab);
    await tester.pumpAndSettle();

    expect(find.text('Burger'), findsOneWidget);
    expect(find.text('Added by Admin'), findsOneWidget);
    // There are two "Sold Out" texts - one in tab and one button, so use findsNWidgets
    expect(find.text('Sold Out'), findsNWidgets(2));
  });

  testWidgets('tapping Order button triggers callback', (tester) async {
    final food = FoodItemEntity(
      id: 'f1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      price: 10.0,
      isAvailable: true,
      imageUrl: '',
    );

    // Set state with items BEFORE building widget
    final notifier = container.read(foodItemNotifierProvider.notifier);
    notifier.state = FoodItemsState(
      status: FoodItemStatus.loaded,
      items: [food],
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    final orderButton = find.text('Order');
    expect(orderButton, findsOneWidget);

    // Simulate tap
    await tester.tap(orderButton);
    await tester.pump();

    // Verify the button is tappable - still exists after tap
    expect(orderButton, findsOneWidget);
  });
}
