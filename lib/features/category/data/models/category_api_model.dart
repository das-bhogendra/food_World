import '../../domain/entities/category_entity.dart';

class CategoryApiModel {
  final String id;
  final String name;
  final String? description;
  final String? addedBy;
  final String? createdAt; // ISO string for API

  CategoryApiModel({
    required this.id,
    required this.name,
    this.description,
    this.addedBy,
    this.createdAt,
  });

  /// Convert from Entity to API model
  factory CategoryApiModel.fromEntity(CategoryEntity entity) => CategoryApiModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        addedBy: entity.createdBy,
        createdAt: entity.createdAt?.toIso8601String(),
      );

  /// Convert from API model to Entity
  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        description: description,
        createdBy: addedBy,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) => CategoryApiModel(
  id: json['_id'] ?? json['id'],
  name: json['name'] ?? '',
  description: json['description'],
  addedBy: json['addedBy'],
  createdAt: json['createdAt'],
);


  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'addedBy': addedBy,
        'createdAt': createdAt,
      };
}
