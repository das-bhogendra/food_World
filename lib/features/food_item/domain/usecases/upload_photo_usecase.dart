import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

final uploadPhotoUsecaseProvider =
    Provider<UploadPhotoUsecase>((ref) {
  final FoodItemsRepository = ref.read(foodItemsRepositoryProvider);
  return UploadPhotoUsecase(repository:FoodItemsRepository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final IFoodItemsRepository _FoodItemsRepository;

  UploadPhotoUsecase({required IFoodItemsRepository repository})
      : _FoodItemsRepository = repository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _FoodItemsRepository.uploadFoodPhoto(photo);
  }
}
