// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromoAdapter extends TypeAdapter<Promo> {
  @override
  final int typeId = 3;

  @override
  Promo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Promo(
      id: fields[0] as int?,
      storeId: fields[1] as int,
      productId: fields[2] as int,
      productName: fields[3] as String,
      normalPrice: fields[4] as double,
      promoPrice: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Promo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storeId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.normalPrice)
      ..writeByte(5)
      ..write(obj.promoPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
