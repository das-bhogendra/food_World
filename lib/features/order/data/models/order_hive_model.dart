import 'package:hive/hive.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'order_hive_model.g.dart';

// Using a unique typeId (7) for OrderItemHiveModel to avoid conflict with FoodItemHiveModel (typeId = 5)
@HiveType(typeId: 7)
class OrderItemHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final int quantity;

  OrderItemHiveModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.quantity,
  });

  // Convert from Entity to Hive Model
  factory OrderItemHiveModel.fromEntity(FoodItem entity) {
    return OrderItemHiveModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      imageUrl: entity.imageUrl,
      quantity: entity.quantity,
    );
  }

  // Convert from Hive Model to Entity
  FoodItem toEntity() {
    return FoodItem(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }
}

@HiveType(typeId: HiveTableConstant.orderTypeId) // Use constant type ID for Order
class OrderHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final List<OrderItemHiveModel> foodItems;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  OrderHiveModel({
    required this.id,
    required this.userId,
    required this.foodItems,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Entity to Hive Model
  factory OrderHiveModel.fromEntity(OrderEntity entity) {
    return OrderHiveModel(
      id: entity.id,
      userId: entity.userId,
      foodItems: entity.foodItems
          .map((f) => OrderItemHiveModel.fromEntity(f))
          .toList(),
      totalAmount: entity.totalAmount,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert from Hive Model to Entity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      foodItems: foodItems.map((f) => f.toEntity()).toList(),
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
