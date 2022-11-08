import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'friend.g.dart';

@HiveType(typeId: 0)
class Friend extends Equatable {
  static const String followersBoxKey = "followersBoxKey";
  static const String followingsBoxKey = "followingsBoxKey";
  static const String newFollowersBoxKey = "newFollowersBoxKey";
  static const String lostFollowersBoxKey = "lostFollowersBoxKey";
  static const String notFollowingBackBoxKey = "notFollowingBackBoxKey";
  static const String youDontFollowBackBoxKey = "youDontFollowBackBoxKey";
  static const String mutualFollowingsBoxKey = "mutualFollowingsBoxKey";
  static const String youHaveUnfollowedBoxKey = "youHaveUnfollowedBoxKey";
  static const String newStoryViewersBoxKey = "newStoryViewersBoxKey";

  // stories
  static const topStoriesViewersBoxKey = 'topStoriesViewersBoxKey';
  static const viewersNotFollowingYouBoxKey = 'viewersNotFollowingYouBoxKey';

  @HiveField(0)
  final int igUserId;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String picture;
  @HiveField(3)
  final DateTime createdOn;
  @HiveField(4)
  final bool? hasBlockedMe;
  @HiveField(5)
  final bool? hasRequestedMe;
  @HiveField(6)
  final bool? requestedByMe;

  const Friend({
    required this.igUserId,
    required this.username,
    required this.picture,
    required this.createdOn,
    required this.hasBlockedMe,
    required this.hasRequestedMe,
    required this.requestedByMe,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        igUserId,
        username,
        picture,
        createdOn,
        hasBlockedMe,
        hasRequestedMe,
        requestedByMe,
      ];
}
