import 'package:equatable/equatable.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;

  /// backend = createdBy
  final String? createdBy;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// optional (backend might not send items always)
  final List<FoodItemEntity> items;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  // ======================= JSON =======================

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
      "createdBy": createdBy,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "items": items.map((e) => e.toJson()).toList(),
    };
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      // ✅ backend sends _id not id
      id: json['_id']?.toString() ?? '',

      // ✅ safe parsing
      name: json['name']?.toString() ?? '',

      // ✅ nullable safe
      description: json['description']?.toString(),

      // ✅ backend sends createdBy not addedBy
      createdBy: json['createdBy']?.toString(),

      // ✅ safe Date parsing
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      // ✅ items optional
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => FoodItemEntity.fromJson(e))
              .toList()
          : [],
    );
  }

  // ======================= CopyWith =======================

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FoodItemEntity>? items,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, createdBy, createdAt, updatedAt, items];
}
