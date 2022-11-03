import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igplus_ios/domain/entities/media_commenters.dart';
import 'package:igplus_ios/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igplus_ios/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// List item representing a single Character with its photo and name.
class MediaCommentersListItem extends StatefulWidget {
  const MediaCommentersListItem({
    required this.mediaCommenters,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final MediaCommenters mediaCommenters;
  final int index;
  final String type;

  @override
  State<MediaCommentersListItem> createState() => _MediaCommentersListItemState();
}

class _MediaCommentersListItemState extends State<MediaCommentersListItem> {
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
          onTap: () => _openProfileLinkOnInsta(widget.mediaCommenters.mediaCommenterList.first.user.username),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              widget.mediaCommenters.mediaCommenterList.first.user.picture,
              errorListener: () => const Icon(
                FontAwesomeIcons.image,
                color: ColorsManager.appBack,
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.mediaCommenters.mediaCommenterList.first.user.username),
          child: SizedBox(
            height: 40.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(widget.mediaCommenters.mediaCommenterList.first.user.username,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                ),
                const SizedBox(height: 4),
                Text(
                    (widget.mediaCommenters.commentsCount > 1)
                        ? '${widget.mediaCommenters.commentsCount} Comments'
                        : '1 Comment',
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
                igUserId: widget.mediaCommenters.mediaCommenterList.first.user.igUserId,
                showFollow: (widget.mediaCommenters.following) ? false : true,
              ),
              const SizedBox(height: 4),
              (widget.mediaCommenters.followedBy)
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
