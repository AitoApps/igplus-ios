// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 1;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      followers: fields[0] as int,
      followings: fields[1] as int,
      notFollowingBack: fields[2] as int,
      youDontFollowBack: fields[3] as int,
      mutualFollowings: fields[4] as int,
      followersChartData: (fields[5] as List).cast<ChartData>(),
      followingsChartData: (fields[6] as List).cast<ChartData>(),
      newFollowersChartData: (fields[7] as List).cast<ChartData>(),
      lostFollowersChartData: (fields[8] as List).cast<ChartData>(),
      newFollowers: fields[9] as int,
      lostFollowers: fields[10] as int,
      youHaveUnfollowed: fields[11] as int,
      newFollowersCycle: fields[12] as int,
      lostFollowersCycle: fields[13] as int,
      youHaveUnfollowedCycle: fields[14] as int,
      notFollowingBackCycle: fields[15] as int,
      youDontFollowBackCycle: fields[16] as int,
      mutualFollowingsCycle: fields[17] as int,
      whoAdmiresYou: (fields[18] as List).cast<LikesAndComments>(),
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.followers)
      ..writeByte(1)
      ..write(obj.followings)
      ..writeByte(2)
      ..write(obj.notFollowingBack)
      ..writeByte(3)
      ..write(obj.youDontFollowBack)
      ..writeByte(4)
      ..write(obj.mutualFollowings)
      ..writeByte(5)
      ..write(obj.followersChartData)
      ..writeByte(6)
      ..write(obj.followingsChartData)
      ..writeByte(7)
      ..write(obj.newFollowersChartData)
      ..writeByte(8)
      ..write(obj.lostFollowersChartData)
      ..writeByte(9)
      ..write(obj.newFollowers)
      ..writeByte(10)
      ..write(obj.lostFollowers)
      ..writeByte(11)
      ..write(obj.youHaveUnfollowed)
      ..writeByte(12)
      ..write(obj.newFollowersCycle)
      ..writeByte(13)
      ..write(obj.lostFollowersCycle)
      ..writeByte(14)
      ..write(obj.youHaveUnfollowedCycle)
      ..writeByte(15)
      ..write(obj.notFollowingBackCycle)
      ..writeByte(16)
      ..write(obj.youDontFollowBackCycle)
      ..writeByte(17)
      ..write(obj.mutualFollowingsCycle)
      ..writeByte(18)
      ..write(obj.whoAdmiresYou);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChartDataAdapter extends TypeAdapter<ChartData> {
  @override
  final int typeId = 3;

  @override
  ChartData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChartData(
      date: fields[0] as String,
      value: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChartData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
