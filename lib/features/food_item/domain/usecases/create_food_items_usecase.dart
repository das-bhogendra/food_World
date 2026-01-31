import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/food_items_repository.dart';
import '../entities/food_items_entity.dart';
import '../repositories/food_items_repository.dart';

/// ================== PARAMS ==================
class CreateFoodItemParams extends Equatable {
  final String name;
  final String? description;
  final FoodItemType type;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String addedBy;

  const CreateFoodItemParams({
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        type,
        price,
        imageUrl,
        isAvailable,
        addedBy,
      ];
}

/// ================== PROVIDER ==================
final createFoodItemUsecaseProvider =
    Provider<CreateFoodItemUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return CreateFoodItemUsecase(foodItemRepository: repository);
});

/// ================== USECASE ==================
class CreateFoodItemUsecase
    implements UsecaseWithParams<bool, CreateFoodItemParams> {
  final IFoodItemsRepository _foodItemRepository;

  CreateFoodItemUsecase({
    required IFoodItemsRepository foodItemRepository,
  }) : _foodItemRepository = foodItemRepository;

  @override
  Future<Either<Failure, bool>> call(CreateFoodItemParams params) {
    final foodItemEntity = FoodItemEntity(
      name: params.name,
      description: params.description,
      type: params.type,
      price: params.price,
      imageUrl: params.imageUrl,
      isAvailable: params.isAvailable,
      addedBy: params.addedBy,
    );

    return _foodItemRepository.createFoodItem(foodItemEntity);
  }
}
