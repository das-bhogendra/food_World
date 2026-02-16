import 'package:equatable/equatable.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

/// ===============================
/// Food Item State Status
/// ===============================
enum FoodItemStatus { initial, loading, loaded, error, created, updated, deleted }

/// ===============================
/// Food Item State
/// ===============================
class FoodItemsState extends Equatable {
  final FoodItemStatus status;

  /// Full list of food items
  final List<FoodItemEntity> items;

  /// Filtered list for search/filter functionality
  final List<FoodItemEntity> filteredItems;

  /// Categorized lists
  final List<FoodItemEntity> vegItems;
  final List<FoodItemEntity> nonVegItems;
  final List<FoodItemEntity> drinkItems;
  final List<FoodItemEntity> dessertItems;

  /// Special lists
  final List<FoodItemEntity> bestSellers;
  final List<FoodItemEntity> discounted;

  /// Selected item for detail/edit
  final FoodItemEntity? selectedItem;

  /// Error message
  final String? errorMessage;

  /// Uploaded media URL (photo/video)
  final String? uploadedMediaUrl;

  const FoodItemsState({
    this.status = FoodItemStatus.initial,
    this.items = const [],
    this.filteredItems = const [],
    this.vegItems = const [],
    this.nonVegItems = const [],
    this.drinkItems = const [],
    this.dessertItems = const [],
    this.bestSellers = const [],
    this.discounted = const [],
    this.selectedItem,
    this.errorMessage,
    this.uploadedMediaUrl,
  });

  FoodItemsState copyWith({
    FoodItemStatus? status,
    List<FoodItemEntity>? items,
    List<FoodItemEntity>? filteredItems,
    List<FoodItemEntity>? vegItems,
    List<FoodItemEntity>? nonVegItems,
    List<FoodItemEntity>? drinkItems,
    List<FoodItemEntity>? dessertItems,
    List<FoodItemEntity>? bestSellers,
    List<FoodItemEntity>? discounted,
    FoodItemEntity? selectedItem,
    String? errorMessage,
    String? uploadedMediaUrl,
  }) {
    return FoodItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      vegItems: vegItems ?? this.vegItems,
      nonVegItems: nonVegItems ?? this.nonVegItems,
      drinkItems: drinkItems ?? this.drinkItems,
      dessertItems: dessertItems ?? this.dessertItems,
      bestSellers: bestSellers ?? this.bestSellers,
      discounted: discounted ?? this.discounted,
      selectedItem: selectedItem ?? this.selectedItem,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedMediaUrl: uploadedMediaUrl ?? this.uploadedMediaUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        filteredItems,
        vegItems,
        nonVegItems,
        drinkItems,
        dessertItems,
        bestSellers,
        discounted,
        selectedItem,
        errorMessage,
        uploadedMediaUrl,
      ];
}
