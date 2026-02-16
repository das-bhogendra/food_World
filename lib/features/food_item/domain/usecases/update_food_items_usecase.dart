import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/food_items_repository.dart';
import '../entities/food_items_entity.dart';
import '../repositories/food_items_repository.dart';

/// =======================
/// Parameters for updating food item
/// =======================
class UpdateFoodItemParams extends Equatable {
  final String id;
  final String name;
  final String? description;
  final FoodItemType type;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String addedBy;
  final bool isBestSeller;
  final bool isDiscounted;

  const UpdateFoodItemParams({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    required this.addedBy,
    this.isBestSeller = false,
    this.isDiscounted = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        price,
        imageUrl,
        isAvailable,
        addedBy,
        isBestSeller,
        isDiscounted,
      ];
}

/// =======================
/// Provider for use case
/// =======================
final updateFoodItemUsecaseProvider =
    Provider<UpdateFoodItemUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return UpdateFoodItemUsecase(foodItemRepository: repository);
});

/// =======================
/// Usecase implementation
/// =======================
class UpdateFoodItemUsecase
    implements UsecaseWithParams<bool, UpdateFoodItemParams> {
  final IFoodItemsRepository _foodItemRepository;

  UpdateFoodItemUsecase({
    required IFoodItemsRepository foodItemRepository,
  }) : _foodItemRepository = foodItemRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateFoodItemParams params) {
    // Map params to FoodItemEntity
    final foodItemEntity = FoodItemEntity(
      id: params.id,
      name: params.name,
      description: params.description,
      type: params.type,
      price: params.price,
      imageUrl: params.imageUrl,
      isAvailable: params.isAvailable,
      addedBy: params.addedBy,
      isBestSeller: params.isBestSeller,
      isDiscounted: params.isDiscounted,
    );

    // Call repository
    return _foodItemRepository.updateFoodItem(foodItemEntity);
  }
}
