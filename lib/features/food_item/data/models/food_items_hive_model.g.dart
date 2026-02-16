// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_items_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodItemHiveModelAdapter extends TypeAdapter<FoodItemHiveModel> {
  @override
  final int typeId = 5;

  @override
  FoodItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItemHiveModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as String,
      price: fields[4] as double,
      imageUrl: fields[5] as String?,
      isAvailable: fields[6] as bool?,
      addedBy: fields[7] as String,
      isBestSeller: fields[8] as bool?,
      isDiscounted: fields[9] as bool?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItemHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.isAvailable)
      ..writeByte(7)
      ..write(obj.addedBy)
      ..writeByte(8)
      ..write(obj.isBestSeller)
      ..writeByte(9)
      ..write(obj.isDiscounted)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
