import 'package:hive/hive.dart';
part 'ig_data_update.g.dart';

enum DataNames {
  accountInfo,
  friends,
  media,
  mediaCommenters,
  mediaLikers,
  report,
  stories,
  storiesUsers,
  storyViwers,
  whoAdmiresYou,
}

@HiveType(typeId: 12)
class IgDataUpdate {
  static const boxKey = 'ig_data_update';

  @HiveField(0)
  final String dataName;
  @HiveField(1)
  final DateTime lastUpdateTime;
  @HiveField(2)
  final DateTime nextUpdateTime;

  IgDataUpdate({
    required this.dataName,
    required this.lastUpdateTime,
    required this.nextUpdateTime,
  });

  // create new IgDataUpdate
  factory IgDataUpdate.create({
    required String dataName,
    required int nextUpdateInMinutes,
  }) {
    return IgDataUpdate(
      dataName: dataName,
      lastUpdateTime: DateTime.now(),
      nextUpdateTime: DateTime.now().subtract(Duration(minutes: -nextUpdateInMinutes)),
    );
  }
}
