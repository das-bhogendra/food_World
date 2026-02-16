import 'package:equatable/equatable.dart';

/// ================= ORDER STATUS CONSTANTS =================
class OrderStatusConstants {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> validStatuses = [
    pending,
    confirmed,
    delivered,
    cancelled,
  ];

  /// Normalize status input
  /// Converts "confirm" -> "confirmed", "deliver" -> "delivered", etc.
  static String normalizeStatus(String status) {
    final s = status.trim().toLowerCase();

    // Auto-correct common typos
    if (s == 'pendin' || s == 'pendng') return pending;

    if (s == 'confirm' || s == 'confrimed' || s == 'cnfirmed') return confirmed;

    if (s == 'deliver' || s == 'delivery' || s == 'delivred') return delivered;

    if (s == 'cancel' || s == 'cancle' || s == 'cnacelled') return cancelled;

    return s;
  }

  /// Check if status is valid
  static bool isValidStatus(String status) {
    return validStatuses.contains(status.trim().toLowerCase());
  }
}

/// ================= FOOD ITEM MODEL =================
class FoodItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final int quantity;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.quantity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, quantity];
}

/// ================= ORDER ENTITY =================
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<FoodItem> foodItems;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.foodItems,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final userData = json['userId'];

    return OrderEntity(
      id: (json['_id'] ?? '').toString(),

      /// Sometimes backend returns:
      /// userId: "xxxxx"
      /// or userId: { _id: "xxxxx" }
      userId: userData is Map
          ? (userData['_id'] ?? '').toString()
          : (userData ?? '').toString(),

      foodItems: (json['foodItems'] as List? ?? [])
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),

      totalAmount: (json['totalAmount'] as num).toDouble(),

      status: OrderStatusConstants.normalizeStatus(
        (json['status'] ?? OrderStatusConstants.pending).toString(),
      ),

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory OrderEntity.empty() {
    return OrderEntity(
      id: '',
      userId: '',
      foodItems: const [],
      totalAmount: 0.0,
      status: OrderStatusConstants.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  OrderEntity copyWith({
    String? id,
    String? userId,
    List<FoodItem>? foodItems,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodItems: foodItems ?? this.foodItems,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, foodItems, totalAmount, status, createdAt, updatedAt];
}
