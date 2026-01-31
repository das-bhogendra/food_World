import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:uuid/uuid.dart';

/// API model for network requests/responses
class FoodItemApiModel {
  final String id;
  final String name;
  final String? description; // ❌ corrected syntax
  final String type; // 'veg', 'nonVeg', 'drink', 'dessert'
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodItemApiModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From JSON (API response → Dart object)
  factory FoodItemApiModel.fromJson(Map<String, dynamic> json) {
    return FoodItemApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      addedBy: json['addedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// To JSON (Dart object → API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert API model → Entity
  FoodItemEntity toEntity() {
    return FoodItemEntity(
      id: id,
      name: name,
      description: description,
      type: FoodItemType.values.firstWhere((e) => e.name == type),
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      addedBy: addedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Entity → API model (null-safety for non-nullable fields)
  factory FoodItemApiModel.fromEntity(FoodItemEntity entity) {
    return FoodItemApiModel(
      id: entity.id ?? const Uuid().v4(), // default if null
      name: entity.name,
      description: entity.description,
      type: entity.type.name , // default if null
      price: entity.price,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
      addedBy: entity.addedBy,
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
  }

  /// Convert list of JSON → list of API models
  static List<FoodItemApiModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => FoodItemApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convert list of API models → list of Entities
  static List<FoodItemEntity> toEntityList(List<FoodItemApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
