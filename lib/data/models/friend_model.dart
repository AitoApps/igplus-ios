import 'package:equatable/equatable.dart';

import '../../domain/entities/friend.dart';

class FriendModel extends Equatable {
  final String igUserId;
  final String username;
  final String picture;

  final DateTime createdOn;
  final bool? hasBlockedMe;
  final bool? hasRequestedMe;
  final bool? requestedByMe;
  const FriendModel({
    required this.igUserId,
    required this.username,
    required this.picture,
    required this.createdOn,
    this.hasBlockedMe,
    this.hasRequestedMe,
    this.requestedByMe,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      igUserId: json['pk'].toString(), //
      username: json['username'],
      picture: json['profile_pic_url'],
      createdOn: DateTime.now(),
      hasBlockedMe: json['has_blocked_viewer'],
      hasRequestedMe: json['has_requested_viewer'],
      requestedByMe: json['requested_by_viewer'],
    );
  }

  factory FriendModel.fromFriend(Friend friend) {
    return FriendModel(
      igUserId: friend.igUserId,
      username: friend.username,
      picture: friend.picture,
      createdOn: friend.createdOn,
      hasBlockedMe: friend.hasBlockedMe,
      hasRequestedMe: friend.hasRequestedMe,
      requestedByMe: friend.requestedByMe,
    );
  }

  Friend toEntity() {
    return Friend(
      igUserId: igUserId,
      username: username,
      picture: picture,
      createdOn: createdOn,
      hasBlockedMe: hasBlockedMe,
      hasRequestedMe: hasRequestedMe,
      requestedByMe: requestedByMe,
    );
  }

  // from entity
  factory FriendModel.fromEntity(Friend entity) {
    return FriendModel(
      igUserId: entity.igUserId,
      username: entity.username,
      picture: entity.picture,
      createdOn: entity.createdOn,
      hasBlockedMe: entity.hasBlockedMe,
      hasRequestedMe: entity.hasRequestedMe,
      requestedByMe: entity.requestedByMe,
    );
  }

  @override
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
