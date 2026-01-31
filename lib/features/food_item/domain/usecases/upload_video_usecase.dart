import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'dart:io';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

final uploadvideoUsecaseProvider =
    Provider<UploadvideoUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return UploadvideoUsecase(repository: repository);
});

class UploadvideoUsecase implements UsecaseWithParams<String, File> {
  final IFoodItemsRepository _repository;

  UploadvideoUsecase({required IFoodItemsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(File video) {
    return _repository.uploadFoodVideo(video);
  }
}
