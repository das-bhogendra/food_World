import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/presentation/pages/report_food_item_page.dart';

// ================= MOCKS =================
class MockFoodItemNotifier extends Mock implements FoodItemNotifier {}
class FakeFoodItemEntity extends Fake implements FoodItemEntity {}
class MockXFile extends Mock implements XFile {}

void main() {
  late MockFoodItemNotifier mockNotifier;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockNotifier = MockFoodItemNotifier();

    // Default initial state
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
        home: const ReportFoodItemPage(),
      ),
    );
  }

  testWidgets('displays form fields and buttons', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Check header
    expect(find.text('Report Food Item'), findsOneWidget);

    // Check form fields
    expect(find.byType(TextFormField), findsNWidgets(2)); // Name & Description
    expect(find.text('Food Name'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    // Check ChoiceChips for availability
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Sold Out'), findsOneWidget);

    // Check Dropdown for type selector
    expect(find.text('Food Type'), findsOneWidget);

    // Check media picker
    expect(find.text('Add Photo / Video'), findsOneWidget);

    // Check submit button
    expect(find.text('Submit Food Item'), findsOneWidget);
  });

  testWidgets('validates empty food name field', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap submit without entering a name
    await tester.tap(find.text('Submit Food Item'));
    await tester.pumpAndSettle();

    // Expect validation error
    expect(find.text('Enter food name'), findsOneWidget);
  });

  testWidgets('can select availability and type', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Sold Out
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((widget) {
      return widget is ChoiceChip && widget.selected == true && (widget.label as Text).data == 'Sold Out';
    }), findsOneWidget);

    // Select food type from dropdown
    await tester.tap(find.byType(DropdownButtonFormField<FoodItemType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NONVEG').last);
    await tester.pumpAndSettle();
    // Should select nonVeg
  });

  testWidgets('enter food name and description', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Pizza');
    await tester.enterText(find.byType(TextFormField).last, 'Delicious cheese pizza');

    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Delicious cheese pizza'), findsOneWidget);
  });

  testWidgets('tapping submit triggers notifier createFoodItem', (tester) async {
    when(() => mockNotifier.createFoodItem(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Burger');

    await tester.tap(find.text('Submit Food Item'));
    await tester.pumpAndSettle();

    verify(() => mockNotifier.createFoodItem(any())).called(1);
  });
}