// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendAdapter extends TypeAdapter<Friend> {
  @override
  final int typeId = 0;

  @override
  Friend read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friend(
      igUserId: fields[0] as String,
      username: fields[1] as String,
      picture: fields[2] as String,
      createdOn: fields[3] as DateTime,
      hasBlockedMe: fields[4] as bool?,
      hasRequestedMe: fields[5] as bool?,
      requestedByMe: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Friend obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.igUserId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.picture)
      ..writeByte(3)
      ..write(obj.createdOn)
      ..writeByte(4)
      ..write(obj.hasBlockedMe)
      ..writeByte(5)
      ..write(obj.hasRequestedMe)
      ..writeByte(6)
      ..write(obj.requestedByMe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
