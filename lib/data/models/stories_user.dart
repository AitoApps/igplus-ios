import 'package:equatable/equatable.dart';
import 'package:igshark/data/models/story_model.dart';
import 'package:igshark/domain/entities/entity_mapper.dart';
import 'package:igshark/domain/entities/stories_user.dart';

class StoriesUserModel extends Equatable {
  final String ownerId;
  final String ownerUsername;
  final String ownerPicUrl;
  final String id;
  final int expiringAt;
  final int latestReelMedia;
  final int seen;
  final List<StoryModel?> stories;
  const StoriesUserModel({
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerPicUrl,
    required this.id,
    required this.expiringAt,
    required this.latestReelMedia,
    required this.seen,
    required this.stories,
  });

  // fromJson
  factory StoriesUserModel.fromJson(Map<String, dynamic> json) {
    return StoriesUserModel(
      ownerId: json['user']['pk'].toString(),
      ownerUsername: json['user']['username'],
      ownerPicUrl: json['user']['profile_pic_url'],
      id: json['id'].toString(),
      expiringAt: json['expiring_at'],
      latestReelMedia: json['latest_reel_media'],
      seen: json['seen'],
      stories: json['items'] != null ? (json['items'] as List).map((e) => StoryModel.fromJson(e)).toList() : [],
    );
  }

  @override
  List<Object?> get props => [ownerId, ownerUsername, ownerPicUrl, id, expiringAt, latestReelMedia, seen];
}

// UserStoryMapper
class UserStoryMapper implements EntityMapper<StoriesUser, StoriesUserModel> {
  @override
  StoriesUser mapToEntity(StoriesUserModel model) {
    final storyOwner = StoryOwner(
      id: model.ownerId,
      username: model.ownerUsername,
      profilePicUrl: model.ownerPicUrl,
    );

    return StoriesUser(
      owner: storyOwner,
      id: model.id,
      expiringAt: model.expiringAt,
      latestReelMedia: model.latestReelMedia,
      seen: model.seen,
      stories: model.stories.map((e) => StoryMapper().mapToEntity(e!)).toList(),
    );
  }

  @override
  StoriesUserModel mapToModel(StoriesUser entity) {
    return StoriesUserModel(
      ownerId: entity.owner.id,
      ownerUsername: entity.owner.username,
      ownerPicUrl: entity.owner.profilePicUrl,
      id: entity.id,
      expiringAt: entity.expiringAt,
      latestReelMedia: entity.latestReelMedia,
      seen: entity.seen,
      stories: entity.stories.map((e) => StoryMapper().mapToModel(e)).toList(),
    );
  }

  List<StoriesUser> mapToEntityList(List<StoriesUserModel> models) {
    return models.map((model) => mapToEntity(model)).toList();
  }

  List<StoriesUserModel> mapToModelList(List<StoriesUser> entities) {
    return entities.map((entity) => mapToModel(entity)).toList();
  }
}
