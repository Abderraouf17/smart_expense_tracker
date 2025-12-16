// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomeSourceAdapter extends TypeAdapter<IncomeSource> {
  @override
  final int typeId = 3;

  @override
  IncomeSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncomeSource(
      title: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as String,
      date: fields[3] as DateTime,
      userId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeSource obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
