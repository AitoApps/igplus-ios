import 'package:igshark/domain/entities/media_commenter.dart';

class MediaCommenters {
  static const boxKey = "mediaCommentersBoxKey";

  final String id;
  final int commentsCount;
  final bool followedBy; // followed me
  final bool following; // i follow
  final List<MediaCommenter> mediaCommenterList;

  MediaCommenters({
    required this.id,
    required this.commentsCount,
    required this.followedBy,
    required this.following,
    required this.mediaCommenterList,
  });
}
