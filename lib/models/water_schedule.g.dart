// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterScheduleAdapter extends TypeAdapter<WaterSchedule> {
  @override
  final int typeId = 0;

  @override
  WaterSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterSchedule(
      id: fields[0] as String,
      plantName: fields[1] as String,
      amount: fields[2] as int,
      reminderTime: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterSchedule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.reminderTime)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
