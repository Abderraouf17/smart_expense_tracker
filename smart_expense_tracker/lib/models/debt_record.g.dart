// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtRecordAdapter extends TypeAdapter<DebtRecord> {
  @override
  final int typeId = 2;

  @override
  DebtRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtRecord(
      amount: fields[0] as double,
      type: fields[1] as String,
      date: fields[2] as DateTime,
      note: fields[3] as String,
      personId: fields[4] as String,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DebtRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.personId)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
