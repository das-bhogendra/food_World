import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/pages/report_food_items_pages.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

// ================= MOCKS =================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

// ================= FALLBACK VALUES =================
class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

void main() {
  late MockFoodItemsRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockRepository = MockFoodItemsRepository();
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('displays form fields', (tester) async {
    // Mock repository to return data immediately
    when(() => mockRepository.getAllFoodItems()).thenAnswer(
      (_) async => const Right<Failure, List<FoodItemEntity>>([]),
    );

    container = ProviderContainer(
      overrides: [
        foodItemsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ReportFoodItemPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Check for form fields
    expect(find.text('Report Food Item'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Sold Out'), findsOneWidget);
    expect(find.text('Food Name'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}
