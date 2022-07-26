import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:igshark/domain/entities/friend.dart';

part 'story.g.dart';

@HiveType(typeId: 7)
class Story extends Equatable {
  static const boxKey = 'storiesBoxKey';

  @HiveField(0)
  final String mediaId;
  @HiveField(1)
  final int takenAt;
  @HiveField(2)
  final String mediaType;
  @HiveField(3)
  final String mediaUrl;
  @HiveField(4)
  final String mediaThumbnailUrl;
  @HiveField(5)
  int? viewersCount;
  @HiveField(6)
  final List<Friend> viewers;

  Story({
    required this.mediaId,
    required this.takenAt,
    required this.mediaType,
    required this.mediaUrl,
    required this.mediaThumbnailUrl,
    required this.viewersCount,
    required this.viewers,
  });

  @override
  List<Object?> get props => [mediaId, takenAt, mediaType, mediaUrl, viewersCount, viewers];
}
