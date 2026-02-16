import 'package:hive/hive.dart';
import '../../domain/entities/category_entity.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 2) // Ensure a unique typeId
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? addedBy;

  @HiveField(4)
  final DateTime createdAt;

  CategoryHiveModel({
    required this.id,
    required this.name,
    this.description,
    this.addedBy,
    required this.createdAt,
  });

  /// Convert HiveModel to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      createdBy: addedBy,
      createdAt: createdAt,
    );
  }

  /// Convert Entity to HiveModel
  factory CategoryHiveModel.fromEntity(CategoryEntity entity) {
    return CategoryHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      addedBy: entity.createdBy,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
  }

  /// Convert list of HiveModels to list of Entities
  static List<CategoryEntity> toEntityList(List<CategoryHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
