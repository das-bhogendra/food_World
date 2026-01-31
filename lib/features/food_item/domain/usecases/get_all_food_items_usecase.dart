import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

/// ================= PROVIDER =================
final getAllFoodItemsUsecaseProvider =
    Provider<GetAllFoodItemsUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return GetAllFoodItemsUsecase(repository: repository);
});

/// ================= USECASE =================
class GetAllFoodItemsUsecase
    implements UsecaseWithoutParams<List<FoodItemEntity>> {
  final IFoodItemsRepository _repository;

  GetAllFoodItemsUsecase({required IFoodItemsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<FoodItemEntity>>> call() {
    return _repository.getAllFoodItems();
  }
}
