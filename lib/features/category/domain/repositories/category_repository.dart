import 'package:dartz/dartz.dart';
import 'package:food_mandu/core/error/failures.dart';
import '../entities/category_entity.dart';

abstract interface class ICategoryRepository {
  /// ================= GET =================
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();

  Future<Either<Failure, CategoryEntity?>> getCategoryById(String categoryId);

  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByUser(String userId);

  /// ================= CREATE / UPDATE / DELETE =================
  Future<Either<Failure, bool>> createCategory(CategoryEntity category);

  Future<Either<Failure, bool>> updateCategory(CategoryEntity category);

  Future<Either<Failure, bool>> deleteCategory(String categoryId);
}
