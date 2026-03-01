import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/pages/food_items_detail_pages.dart';

void main() {
  late FoodItemEntity availableFood;
  late FoodItemEntity soldOutFood;

  setUp(() {
    availableFood = FoodItemEntity(
      id: '1',
      name: 'Pizza',
      addedBy: 'Admin',
      type: FoodItemType.veg,
      price: 10.99,
      isAvailable: true,
      imageUrl: '', // empty to test placeholder
      description: 'Delicious cheese pizza',
    );

    soldOutFood = FoodItemEntity(
      id: '2',
      name: 'Burger',
      addedBy: 'Admin',
      type: FoodItemType.nonVeg,
      price: 8.99,
      isAvailable: false,
      imageUrl: '', // empty to test placeholder
      description: 'Juicy beef burger',
    );
  });

  Widget createTestWidget(FoodItemEntity foodItem) {
    return MaterialApp(
      home: FoodItemDetailPage(
        foodItem: foodItem,
        category: 'Fast Food',
        location: 'Kathmandu',
      ),
    );
  }

  testWidgets('displays food details for available item', (tester) async {
    await tester.pumpWidget(createTestWidget(availableFood));
    await tester.pumpAndSettle();

    // Name, category, location, addedBy, description
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Fast Food'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
    expect(find.text('Added by'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Delicious cheese pizza'), findsOneWidget);

    // Button shows "Order Now"
    expect(find.text('Order Now'), findsOneWidget);
  });

  testWidgets('displays food details for sold out item', (tester) async {
    await tester.pumpWidget(createTestWidget(soldOutFood));
    await tester.pumpAndSettle();

    // Name, category, location, addedBy, description
    expect(find.text('Burger'), findsOneWidget);
    expect(find.text('Fast Food'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
    expect(find.text('Added by'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Juicy beef burger'), findsOneWidget);

    // Button shows "Sold Out"
    expect(find.text('Sold Out'), findsOneWidget);
  });

  testWidgets('shows order dialog on tapping "Order Now"', (tester) async {
    await tester.pumpWidget(createTestWidget(availableFood));
    await tester.pumpAndSettle();

    // Tap "Order Now"
    await tester.tap(find.text('Order Now'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Order Food Item'), findsOneWidget);
    expect(find.text('Do you want to order this item?'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('shows sold out dialog on tapping "Sold Out"', (tester) async {
    await tester.pumpWidget(createTestWidget(soldOutFood));
    await tester.pumpAndSettle();

    // Tap "Sold Out"
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('This food item is currently sold out.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
