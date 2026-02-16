import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';

final foodItemNotifierProvider =
    NotifierProvider<FoodItemNotifier, FoodItemsState>(
  FoodItemNotifier.new,
);

class FoodItemNotifier extends Notifier<FoodItemsState> {
  late final IFoodItemsRepository repository;

  @override
  FoodItemsState build() {
    repository = ref.read(foodItemsRepositoryProvider);
    return const FoodItemsState();
  }

  Future<void> createFoodItem(FoodItemEntity foodItem, {File? imageFile}) async {
    try {
      state = state.copyWith(status: FoodItemStatus.loading);

      final result = await repository.createFoodItem(
        foodItem,
        imageFile: imageFile,
      );

      result.fold(
        (failure) {
          state = state.copyWith(status: FoodItemStatus.error, errorMessage: failure.message);
        },
        (_) async {
          await fetchFoodItems();
          state = state.copyWith(status: FoodItemStatus.created);
        },
      );
    } catch (e) {
      state = state.copyWith(status: FoodItemStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> updateFoodItem(FoodItemEntity foodItem, {File? imageFile}) async {
    try {
      state = state.copyWith(status: FoodItemStatus.loading);

      final result = await repository.updateFoodItem(
        foodItem,
        imageFile: imageFile,
      );

      result.fold(
        (failure) {
          state = state.copyWith(status: FoodItemStatus.error, errorMessage: failure.message);
        },
        (_) async {
          await fetchFoodItems();
          state = state.copyWith(status: FoodItemStatus.updated);
        },
      );
    } catch (e) {
      state = state.copyWith(status: FoodItemStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> fetchFoodItems() async {
    try {
      state = state.copyWith(status: FoodItemStatus.loading);

      final result = await repository.getAllFoodItems();

      result.fold(
        (failure) {
          state = state.copyWith(status: FoodItemStatus.error, errorMessage: failure.message);
        },
        (items) {
          state = state.copyWith(
            status: FoodItemStatus.loaded,
            items: items,
            filteredItems: items,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(status: FoodItemStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      state = state.copyWith(status: FoodItemStatus.loading);

      final result = await repository.deleteFoodItem(id);

      result.fold(
        (failure) {
          state = state.copyWith(status: FoodItemStatus.error, errorMessage: failure.message);
        },
        (_) async {
          await fetchFoodItems();
          state = state.copyWith(status: FoodItemStatus.deleted);
        },
      );
    } catch (e) {
      state = state.copyWith(status: FoodItemStatus.error, errorMessage: e.toString());
    }
  }

  Future<String?> uploadMedia(File file, {bool isVideo = false}) async {
    try {
      final result = isVideo
          ? await repository.uploadFoodVideo(file)
          : await repository.uploadFoodPhoto(file);

      return result.fold(
        (failure) {
          state = state.copyWith(status: FoodItemStatus.error, errorMessage: failure.message);
          return null;
        },
        (url) {
          state = state.copyWith(uploadedMediaUrl: url);
          return url;
        },
      );
    } catch (e) {
      state = state.copyWith(status: FoodItemStatus.error, errorMessage: e.toString());
      return null;
    }
  }

  Future<String?> uploadPhoto(File photo) => uploadMedia(photo, isVideo: false);
  Future<String?> uploadVideo(File video) => uploadMedia(video, isVideo: true);

  void selectFoodItem(FoodItemEntity item) {
    state = state.copyWith(selectedItem: item);
  }

  void resetUploadedMediaUrl() {
    state = state.copyWith(uploadedMediaUrl: null);
  }

  void filterFoodItems(String query) {
    final allItems = state.items;

    if (query.isEmpty) {
      state = state.copyWith(filteredItems: allItems);
    } else {
      final filtered = allItems
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();

      state = state.copyWith(filteredItems: filtered);
    }
  }
}
