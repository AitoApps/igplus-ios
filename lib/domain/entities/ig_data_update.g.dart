// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ig_data_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IgDataUpdateAdapter extends TypeAdapter<IgDataUpdate> {
  @override
  final int typeId = 12;

  @override
  IgDataUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IgDataUpdate(
      dataName: fields[0] as String,
      lastUpdateTime: fields[1] as DateTime,
      nextUpdateTime: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, IgDataUpdate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dataName)
      ..writeByte(1)
      ..write(obj.lastUpdateTime)
      ..writeByte(2)
      ..write(obj.nextUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IgDataUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
