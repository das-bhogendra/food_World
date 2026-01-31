import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

final foodItemsViewModelProvider =
    NotifierProvider<FoodItemsViewModel, FoodItemState>(
  () => FoodItemsViewModel(),
);

class FoodItemsViewModel extends Notifier<FoodItemState> {
  @override
  FoodItemState build() {
    // Initial state
    return const FoodItemState();
  }

  /// ================= LOAD FOOD ITEMS =================
  Future<void> loadFoodItems() async {
    state = state.copyWith(status: FoodItemStatus.loading);

    try {
      // TEMP DUMMY DATA (later API / Usecase)
      final items = [
        FoodItemEntity(
          id: '1',
          name: 'Veg Momo',
          description: 'Steamed veg momos',
          type: FoodItemType.veg,
          price: 120,
          addedBy: 'admin',
        ),
        FoodItemEntity(
          id: '2',
          name: 'Chicken Burger',
          type: FoodItemType.nonVeg,
          price: 250,
          addedBy: 'admin',
        ),
      ];

      state = state.copyWith(
        status: FoodItemStatus.loaded,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        status: FoodItemStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// ================= CREATE FOOD ITEM =================
  Future<void> createFoodItem({
    required String name,
    String? description,
    required FoodItemType type,
    required double price,
    required bool isAvailable,
    required String addedBy,
    String? imageUrl,
    String? mediaType,
  }) async {
    state = state.copyWith(status: FoodItemStatus.loading);

    try {
      // Create new item (dummy id and createdAt)
      final newItem = FoodItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        type: type,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        addedBy: addedBy,
        createdAt: DateTime.now(),
      );

      final updatedItems = List<FoodItemEntity>.from(state.items)
        ..add(newItem);

      state = state.copyWith(
        status: FoodItemStatus.created,
        items: updatedItems,
        uploadedMediaUrl: null, // reset uploaded media
      );
    } catch (e) {
      state = state.copyWith(
        status: FoodItemStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// ================= UPLOAD MEDIA =================
  Future<void> uploadPhoto(File file) async {
    // Dummy uploaded URL
    final url = 'https://dummyurl.com/${file.path.split('/').last}';
    state = state.copyWith(uploadedMediaUrl: url);
  }

  Future<void> uploadVideo(File file) async {
    // Dummy uploaded URL
    final url = 'https://dummyurl.com/${file.path.split('/').last}';
    state = state.copyWith(uploadedMediaUrl: url);
  }
}
