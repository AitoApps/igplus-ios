import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/story_viewer.dart';
import 'package:igshark/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
import 'package:igshark/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

/// List item representing a single Character with its photo and name.
class StoryViewerListItem extends StatefulWidget {
  const StoryViewerListItem({
    required this.storyViewer,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final StoryViewer storyViewer;
  final int index;
  final String type;

  @override
  State<StoryViewerListItem> createState() => _StoryViewerListItemState();
}

class _StoryViewerListItemState extends State<StoryViewerListItem> {
  // initShowFollowButton
  bool showFollowButton = true;

  @override
  Widget build(BuildContext context) {
    if (widget.storyViewer.following == true) {
      showFollowButton = false;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tileColor: ColorsManager.cardBack,
        leading: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.storyViewer.user.username),
          child: Stack(children: [
            CircularCachedImage(picture: widget.storyViewer.user.picture, username: widget.storyViewer.user.username),
            (widget.storyViewer.hasLiked)
                ? const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      // shadow
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                          offset: Offset(0.0, 0.0),
                        ),
                      ],
                      FontAwesomeIcons.solidHeart,
                      color: Colors.red,
                      size: 16,
                    ))
                : const SizedBox.shrink()
          ]),
        ),
        title: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.storyViewer.user.username),
          child: SizedBox(
            height: 40.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(widget.storyViewer.user.username,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                ),
                const SizedBox(height: 4),
                Text(timeago.format(widget.storyViewer.user.createdOn),
                    style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
              ],
            ),
          ),
        ),
        trailing: FollowUnfollowButton(
          igUserId: widget.storyViewer.user.igUserId,
          showFollow: showFollowButton,
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
