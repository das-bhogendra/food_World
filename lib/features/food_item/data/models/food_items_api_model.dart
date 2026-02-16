import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:uuid/uuid.dart';

/// API model for network requests/responses
class FoodItemApiModel {
  final String id;
  final String name;
  final String? description;
  final String type; // 'veg', 'nonVeg', 'drink', 'dessert'
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String? addedBy; // ❌ make optional
  final bool isBestSeller;
  final bool isDiscounted;
  final DateTime? createdAt; // optional for create/update
  final DateTime? updatedAt; // optional for create/update

  FoodItemApiModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.addedBy,
    this.isBestSeller = false,
    this.isDiscounted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// From JSON (API response → Dart object)
  factory FoodItemApiModel.fromJson(Map<String, dynamic> json) {
    return FoodItemApiModel(
      id: json['_id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'veg',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      addedBy: json['addedBy'] as String?,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      isDiscounted: json['isDiscounted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  /// To JSON (Dart object → API request)
  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isBestSeller': isBestSeller,
      'isDiscounted': isDiscounted,
    };

    // include addedBy only if not null
    if (addedBy != null) data['addedBy'] = addedBy;

    // include createdAt/updatedAt only if not null
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }

  /// Convert API model → Entity
  FoodItemEntity toEntity() {
    return FoodItemEntity(
      id: id,
      name: name,
      description: description,
      type: FoodItemType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => FoodItemType.veg,
      ),
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      addedBy: addedBy ?? 'Unknown', // fallback if null
      isBestSeller: isBestSeller,
      isDiscounted: isDiscounted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Entity → API model
  factory FoodItemApiModel.fromEntity(FoodItemEntity entity) {
    return FoodItemApiModel(
      id: entity.id ?? const Uuid().v4(),
      name: entity.name,
      description: entity.description,
      type: entity.type.name,
      price: entity.price,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
      addedBy: entity.addedBy,
      isBestSeller: entity.isBestSeller,
      isDiscounted: entity.isDiscounted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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
