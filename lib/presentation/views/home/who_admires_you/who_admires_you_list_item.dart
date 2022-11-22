import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
import 'package:igshark/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// List item representing a single Character with its photo and name.
class WhoAdmiresYouListItem extends StatefulWidget {
  const WhoAdmiresYouListItem({
    required this.whoAdmiresYou,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final LikesAndComments whoAdmiresYou;
  final int index;
  final String type;

  @override
  State<WhoAdmiresYouListItem> createState() => _WhoAdmiresYouListItemState();
}

class _WhoAdmiresYouListItemState extends State<WhoAdmiresYouListItem> {
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
          onTap: () => _openProfileLinkOnInsta(widget.whoAdmiresYou.user.username),
          child: CircularCachedImage(
              picture: widget.whoAdmiresYou.user.picture, username: widget.whoAdmiresYou.user.username),
        ),
        title: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.whoAdmiresYou.user.username),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 40.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(widget.whoAdmiresYou.user.username,
                        overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(widget.whoAdmiresYou.likesCount.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(FontAwesomeIcons.thumbsUp, color: ColorsManager.secondarytextColor, size: 12),
                      const SizedBox(width: 8),
                      Text(widget.whoAdmiresYou.commentsCount.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(FontAwesomeIcons.comment, color: ColorsManager.secondarytextColor, size: 12),
                      const SizedBox(width: 8),
                      Text(
                          (widget.whoAdmiresYou.total > 1)
                              ? '${widget.whoAdmiresYou.total} Points'
                              : '${widget.whoAdmiresYou.total} Point',
                          style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
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
                igUserId: widget.whoAdmiresYou.user.igUserId,
                showFollow: (widget.whoAdmiresYou.following) ? false : true,
              ),
              const SizedBox(height: 4),
              (widget.whoAdmiresYou.followedBy)
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
