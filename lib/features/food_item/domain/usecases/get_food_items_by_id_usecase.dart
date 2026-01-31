import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

/// ================= PARAMS =================
class GetFoodItemByIdParams extends Equatable {
  final String foodItemId;

  const GetFoodItemByIdParams({
    required this.foodItemId,
  });

  @override
  List<Object?> get props => [foodItemId];
}

/// ================= PROVIDER =================
final getFoodItemByIdUsecaseProvider =
    Provider<GetFoodItemByIdUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return GetFoodItemByIdUsecase(repository: repository);
});

/// ================= USECASE =================
class GetFoodItemByIdUsecase
    implements UsecaseWithParams<FoodItemEntity, GetFoodItemByIdParams> {
  final IFoodItemsRepository _repository;

  GetFoodItemByIdUsecase({required IFoodItemsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FoodItemEntity>> call(
      GetFoodItemByIdParams params) {
    return _repository.getFoodItemById(params.foodItemId);
  }
}
