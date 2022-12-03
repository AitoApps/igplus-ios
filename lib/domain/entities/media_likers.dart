import 'package:igshark/domain/entities/media_liker.dart';

class MediaLikers {
  static const boxKey = "mediaLikersBoxKey";

  final String id;
  final int likesCount;
  final bool followedBy; // followed me
  final bool following; // i follow
  final List<MediaLiker> mediaLikerList;

  MediaLikers({
    required this.id,
    required this.likesCount,
    required this.followedBy,
    required this.following,
    required this.mediaLikerList,
  });
}
