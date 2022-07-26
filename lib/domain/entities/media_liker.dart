import 'package:hive/hive.dart';
import 'package:igshark/domain/entities/friend.dart';

part 'media_liker.g.dart';

@HiveType(typeId: 9)
class MediaLiker {
  static const boxKey = 'mediaLikersBoxKey';

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String mediaId;
  @HiveField(2)
  final Friend user;

  MediaLiker({
    required this.id,
    required this.mediaId,
    required this.user,
  });
}
