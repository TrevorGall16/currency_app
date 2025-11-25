// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyCardAdapter extends TypeAdapter<CurrencyCard> {
  @override
  final int typeId = 0;

  @override
  CurrencyCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyCard(
      id: fields[0] as String,
      base: fields[1] as String,
      target: fields[2] as String,
      rate: fields[3] as double,
      lastUpdated: fields[4] as DateTime,
      historicalData: (fields[5] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.base)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.rate)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.historicalData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
