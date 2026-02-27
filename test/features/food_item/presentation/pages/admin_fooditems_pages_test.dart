import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ================= MOCK ENTITIES & STATE =================
class FoodItemEntity {
  final String id;
  final String name;
  final String addedBy;
  final bool isAvailable;
  final String? fullImageUrl;

  FoodItemEntity({
    required this.id,
    required this.name,
    required this.addedBy,
    this.isAvailable = true,
    this.fullImageUrl,
  });
}

enum FoodItemStatus { initial, loading, loaded, error }

class FoodItemsState {
  final FoodItemStatus status;
  final List<FoodItemEntity> items;

  FoodItemsState({required this.status, required this.items});

  factory FoodItemsState.initial() => FoodItemsState(status: FoodItemStatus.initial, items: []);

  FoodItemsState copyWith({FoodItemStatus? status, List<FoodItemEntity>? items}) {
    return FoodItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

// ================= MOCK NOTIFIER =================
class FoodItemNotifier extends StateNotifier<FoodItemsState> {
  FoodItemNotifier() : super(FoodItemsState.initial());

  void fetchFoodItems() {
    // Mock fetch
    state = state.copyWith(
      status: FoodItemStatus.loaded,
      items: [
        FoodItemEntity(id: '1', name: 'Pizza', addedBy: 'Admin', isAvailable: true),
        FoodItemEntity(id: '2', name: 'Burger', addedBy: 'Admin', isAvailable: true),
        FoodItemEntity(id: '3', name: 'Pasta', addedBy: 'Admin', isAvailable: false),
      ],
    );
  }

  void deleteFoodItem(String id) {
    state = state.copyWith(items: state.items.where((f) => f.id != id).toList());
  }
}

// ================= PROVIDER =================
final foodItemNotifierProvider =
    StateNotifierProvider<FoodItemNotifier, FoodItemsState>((ref) {
  return FoodItemNotifier();
});

// ================= ADMIN FOOD ITEMS PAGE =================
class AdminFoodItemsPage extends ConsumerStatefulWidget {
  const AdminFoodItemsPage({super.key});

  @override
  ConsumerState<AdminFoodItemsPage> createState() => _AdminFoodItemsPageState();
}

class _AdminFoodItemsPageState extends ConsumerState<AdminFoodItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(foodItemNotifierProvider.notifier).fetchFoodItems());
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodItemNotifierProvider);
    final notifier = ref.read(foodItemNotifierProvider.notifier);

    final availableItems = foodState.items.where((e) => e.isAvailable).toList();
    final soldOutItems = foodState.items.where((e) => !e.isAvailable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Food Items"),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Available (${availableItems.length})"),
            Tab(text: "Sold Out (${soldOutItems.length})"),
          ],
        ),
      ),
      body: foodState.status == FoodItemStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFoodList(context, availableItems, true, notifier),
                _buildFoodList(context, soldOutItems, false, notifier),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          notifier.fetchFoodItems(); // mock refresh
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFoodList(
      BuildContext context, List<FoodItemEntity> items, bool available, FoodItemNotifier notifier) {
    if (items.isEmpty) {
      return Center(child: Text(available ? 'No available items' : 'No sold out items'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final food = items[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: food.fullImageUrl != null
                ? Image.network(food.fullImageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                : Container(width: 56, height: 56, color: Colors.grey),
            title: Text(food.name),
            subtitle: Text('Added by: ${food.addedBy}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {}, // mock edit
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => notifier.deleteFoodItem(food.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= WIDGET TEST =================
class MockFoodItemNotifier extends Mock implements FoodItemNotifier {}

class FakeFoodItemEntity extends Fake implements FoodItemEntity {}

void main() {
  late ProviderContainer container;
  late MockFoodItemNotifier mockNotifier;

  setUpAll(() {
    registerFallbackValue(FakeFoodItemEntity());
  });

  setUp(() {
    mockNotifier = MockFoodItemNotifier();

    when(() => mockNotifier.state).thenReturn(FoodItemsState.initial());

    container = ProviderContainer(
      overrides: [
        foodItemNotifierProvider.overrideWithValue(mockNotifier),
      ],
    );
  });

  tearDown(() => container.dispose());

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AdminFoodItemsPage()),
    );
  }

  testWidgets('should show loading indicator when loading', (tester) async {
    when(() => mockNotifier.state).thenReturn(
      FoodItemsState(status: FoodItemStatus.loading, items: []),
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show available and sold out items', (tester) async {
    final food1 = FoodItemEntity(id: '1', name: 'Pizza', addedBy: 'Admin', isAvailable: true);
    final food2 = FoodItemEntity(id: '2', name: 'Pasta', addedBy: 'Admin', isAvailable: false);

    when(() => mockNotifier.state).thenReturn(
      FoodItemsState(status: FoodItemStatus.loaded, items: [food1, food2]),
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Check tabs titles
    expect(find.text('Available (1)'), findsOneWidget);
    expect(find.text('Sold Out (1)'), findsOneWidget);

    // Check food items in list
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
  });

  testWidgets('should delete item when delete button is tapped', (tester) async {
    final food1 = FoodItemEntity(id: '1', name: 'Pizza', addedBy: 'Admin', isAvailable: true);

    when(() => mockNotifier.state).thenReturn(
      FoodItemsState(status: FoodItemStatus.loaded, items: [food1]),
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Pizza'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    verify(() => mockNotifier.deleteFoodItem(food1.id)).called(1);
  });
}