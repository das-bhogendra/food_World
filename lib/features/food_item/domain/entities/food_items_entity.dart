import 'package:equatable/equatable.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';

enum FoodItemType { veg, nonVeg, drink, dessert }

class FoodItemEntity extends Equatable {
  final String id;
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
  final bool isBestSeller; // <-- important for Best Seller page
  final bool isDiscounted; // <-- important for Discount page

  const FoodItemEntity({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.imageUrl,
    this.mediaType,
    this.isAvailable = true,
    required this.addedBy,
    this.isBestSeller = false,
    this.isDiscounted = false,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ fromJson (Database/API बाट आउने data parse गर्न)
  factory FoodItemEntity.fromJson(Map<String, dynamic> json) {
    return FoodItemEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: _parseFoodType(json['type']),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      mediaType: json['mediaType'],
      isAvailable: json['isAvailable'] ?? true,
      addedBy: json['addedBy']?.toString() ?? '',
      isBestSeller: json['isBestSeller'] ?? false,
      isDiscounted: json['isDiscounted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // ✅ toJson (Create/Update गर्दा backend मा पठाउन)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'price': price,
      'imageUrl': imageUrl,
      'mediaType': mediaType,
      'isAvailable': isAvailable,
      'addedBy': addedBy,
      'isBestSeller': isBestSeller,
      'isDiscounted': isDiscounted,
    };
  }

  // ✅ Helper: type parse गर्ने
  static FoodItemType _parseFoodType(dynamic value) {
    if (value == null) return FoodItemType.veg;

    final v = value.toString().toLowerCase();

    if (v == 'nonveg' || v == 'non_veg' || v == 'non-veg') {
      return FoodItemType.nonVeg;
    }
    if (v == 'drink') return FoodItemType.drink;
    if (v == 'dessert') return FoodItemType.dessert;

    return FoodItemType.veg;
  }

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
    bool? isBestSeller,
    bool? isDiscounted,
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
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String? get fullImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // If already a full URL, return as is
      if (imageUrl!.startsWith('http')) {
        return imageUrl;
      }
      // If starts with /public/, prepend server URL (without /api)
      if (imageUrl!.startsWith('/public/')) {
        // Get server URL without /api suffix
        final serverUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
        return '$serverUrl$imageUrl';
      }
      // Otherwise, prepend server URL with /uploads/
      return '${ApiEndpoints.baseUrl}/uploads/$imageUrl';
    }
    return null;
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
        isBestSeller,
        isDiscounted,
        createdAt,
        updatedAt,
      ];
}
