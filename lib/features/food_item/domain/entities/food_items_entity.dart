import 'package:equatable/equatable.dart';

enum FoodItemType { veg, nonVeg, drink, dessert }

class FoodItemEntity extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final FoodItemType type;
  final double price;
  final String? imageUrl;
  final String? mediaType; // 'photo' or 'video'
  final bool isAvailable;
  final String addedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodItemEntity({
    this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    this.mediaType,
    this.isAvailable = true,
    required this.addedBy,
    this.createdAt,
    this.updatedAt,
  });

  FoodItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    FoodItemType? type,
    double? price,
    String? imageUrl,
    String? mediaType,
    bool? isAvailable,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      isAvailable: isAvailable ?? this.isAvailable,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        price,
        imageUrl,
        mediaType,
        isAvailable,
        addedBy,
        createdAt,
        updatedAt,
      ];
}
