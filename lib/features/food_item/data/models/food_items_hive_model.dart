import 'package:hive/hive.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:uuid/uuid.dart';

part 'food_items_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.foodItemTypeId)
class FoodItemHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String type; // 'veg', 'nonVeg', 'drink', 'dessert'

  @HiveField(4)
  final double price;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final bool isAvailable;

  @HiveField(7)
  final String addedBy;

  @HiveField(8)
  final bool isBestSeller; // ✅ Added

  @HiveField(9)
  final bool isDiscounted; // ✅ Added

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  FoodItemHiveModel({
    String? id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    bool? isAvailable,
    required this.addedBy,
    bool? isBestSeller,
    bool? isDiscounted,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        isAvailable = isAvailable ?? true,
        isBestSeller = isBestSeller ?? false,
        isDiscounted = isDiscounted ?? false,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Hive model → Entity
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
      isBestSeller: isBestSeller,
      isDiscounted: isDiscounted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Entity → Hive model
  factory FoodItemHiveModel.fromEntity(FoodItemEntity entity) {
    return FoodItemHiveModel(
      id: entity.id,
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

  /// Convert list of Hive models → list of Entities
  static List<FoodItemEntity> toEntityList(List<FoodItemHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
