import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

/// ================= PARAMS =================
class GetFoodItemsByUserParams extends Equatable {
  final String userId;

  const GetFoodItemsByUserParams({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

/// ================= PROVIDER =================
final getFoodItemsByUserUsecaseProvider =
    Provider<GetFoodItemsByUserUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return GetFoodItemsByUserUsecase(repository: repository);
});

/// ================= USECASE =================
class GetFoodItemsByUserUsecase
    implements
        UsecaseWithParams<List<FoodItemEntity>, GetFoodItemsByUserParams> {
  final IFoodItemsRepository _repository;

  GetFoodItemsByUserUsecase({required IFoodItemsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<FoodItemEntity>>> call(
      GetFoodItemsByUserParams params) {
    return _repository.getFoodItemsByUser(params.userId);
  }
}
