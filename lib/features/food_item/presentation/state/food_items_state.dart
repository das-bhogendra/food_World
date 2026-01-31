import 'package:equatable/equatable.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';



enum FoodItemStatus { initial, loading, loaded, error, created, updated, deleted }

class FoodItemState extends Equatable {
  final FoodItemStatus status;
  final List<FoodItemEntity> items;
  final List<FoodItemEntity> vegItems;
  final List<FoodItemEntity> nonVegItems;
  final List<FoodItemEntity> drinkItems;
  final List<FoodItemEntity> dessertItems;
  final FoodItemEntity? selectedItem;
  final String? errorMessage;
  final String? uploadedMediaUrl;

  const FoodItemState({
    this.status = FoodItemStatus.initial,
    this.items = const [],
    this.vegItems = const [],
    this.nonVegItems = const [],
    this.drinkItems = const [],
    this.dessertItems = const [],
    this.selectedItem,
    this.errorMessage,
    this.uploadedMediaUrl,
  });

  FoodItemState copyWith({
    FoodItemStatus? status,
    List<FoodItemEntity>? items,
    List<FoodItemEntity>? vegItems,
    List<FoodItemEntity>? nonVegItems,
    List<FoodItemEntity>? drinkItems,
    List<FoodItemEntity>? dessertItems,
    FoodItemEntity? selectedItem,
    String? errorMessage,
    String? uploadedMediaUrl,
  }) {
    return FoodItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      vegItems: vegItems ?? this.vegItems,
      nonVegItems: nonVegItems ?? this.nonVegItems,
      drinkItems: drinkItems ?? this.drinkItems,
      dessertItems: dessertItems ?? this.dessertItems,
      selectedItem: selectedItem ?? this.selectedItem,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedMediaUrl: uploadedMediaUrl ?? this.uploadedMediaUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        vegItems,
        nonVegItems,
        drinkItems,
        dessertItems,
        selectedItem,
        errorMessage,
        uploadedMediaUrl,
      ];
}
