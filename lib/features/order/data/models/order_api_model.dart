import '../../domain/entities/order_entity.dart';

class OrderApiModel {
  final String id;
  final String userId;
  final double totalAmount;

  /// ✅ Full objects with quantity
  final List<FoodItem> foodItems;

  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderApiModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.foodItems,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // ================= JSON -> Model =================
  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    // Handle userId which can be a string or object
    String userId;
    if (json['userId'] is Map) {
      userId = (json['userId']['_id'] ?? '').toString();
    } else {
      userId = (json['userId'] ?? '').toString();
    }

    // Handle foodItems (full objects)
    List<FoodItem> foodItems = [];

    if (json['foodItems'] is List) {
      foodItems = (json['foodItems'] as List).map((item) {
        if (item is Map<String, dynamic>) {
          return FoodItem(
            id: (item['_id'] ?? item['id'] ?? '').toString(),
            name: (item['name'] ?? '').toString(),
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: item['imageUrl']?.toString(),
            quantity: (item['quantity'] as int?) ?? 1,
          );
        } else {
          // fallback
          return FoodItem(
            id: item.toString(),
            name: '',
            price: 0.0,
            imageUrl: null,
            quantity: 1,
          );
        }
      }).toList();
    }

    return OrderApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: userId,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      foodItems: foodItems,
      status: (json['status'] ?? 'pending').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  // ================= Model -> JSON =================
  /// ✅ Send full objects + quantity to backend
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "totalAmount": totalAmount,
      "foodItems": foodItems
          .map((f) => {
                "_id": f.id,
                "name": f.name,
                "price": f.price,
                "imageUrl": f.imageUrl,
                "quantity": f.quantity,
              })
          .toList(),
      "status": status,
    };
  }

  // ================= Model -> Entity =================
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      foodItems: foodItems,
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ================= Entity -> Model =================
  factory OrderApiModel.fromEntity(OrderEntity entity) {
    return OrderApiModel(
      id: entity.id,
      userId: entity.userId,
      totalAmount: entity.totalAmount,
      foodItems: entity.foodItems,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
