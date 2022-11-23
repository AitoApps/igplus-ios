import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/media_likers.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
import 'package:igshark/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// List item representing a single Character with its photo and name.
class MediaLikersListItem extends StatefulWidget {
  const MediaLikersListItem({
    required this.mediaLikers,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final MediaLikers mediaLikers;
  final int index;
  final String type;

  @override
  State<MediaLikersListItem> createState() => _MediaLikersListItemState();
}

class _MediaLikersListItemState extends State<MediaLikersListItem> {
  // initShowFollowButton
  bool showFollowButton = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tileColor: ColorsManager.cardBack,
        leading: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.mediaLikers.mediaLikerList.first.user.username),
          child: CircularCachedImage(
              picture: widget.mediaLikers.mediaLikerList.first.user.picture,
              username: widget.mediaLikers.mediaLikerList.first.user.username),
        ),
        title: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.mediaLikers.mediaLikerList.first.user.username),
          child: SizedBox(
            height: 40.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(widget.mediaLikers.mediaLikerList.first.user.username,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                ),
                const SizedBox(height: 4),
                Text(
                    (widget.mediaLikers.likesCount == 0)
                        ? 'no likes'
                        : (widget.mediaLikers.likesCount == 1)
                            ? '1 like'
                            : '${widget.mediaLikers.likesCount} likes',
                    style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
              ],
            ),
          ),
        ),
        trailing: SizedBox(
          width: 78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FollowUnfollowButton(
                igUserId: widget.mediaLikers.mediaLikerList.first.user.igUserId,
                showFollow: (widget.mediaLikers.following) ? false : true,
              ),
              const SizedBox(height: 4),
              (widget.mediaLikers.followedBy)
                  ? Row(
                      children: const [
                        Icon(FontAwesomeIcons.squareCheck, color: ColorsManager.upColor, size: 8),
                        SizedBox(width: 4),
                        Text("Following you", style: TextStyle(color: ColorsManager.secondarytextColor, fontSize: 10)),
                      ],
                    )
                  : Row(
                      children: const [
                        Icon(FontAwesomeIcons.xmark, color: ColorsManager.downColor, size: 8),
                        SizedBox(width: 4),
                        Text("Not following", style: TextStyle(color: ColorsManager.secondarytextColor, fontSize: 10)),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfileLinkOnInsta(String username) async {
    var url = 'instagram://user?username=$username';
    Uri uri = Uri.parse(url);
    try {
      var rs = await launchUrl(
        uri,
      );
      if (rs == false) {
        var url = 'https://instagram.com/$username';
        Uri uri = Uri.parse(url);
        await launchUrl(
          uri,
        );
      }
    } catch (e) {
      throw 'There was a problem to open the url: $url';
    }
  }
}
