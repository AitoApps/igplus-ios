import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:igplus_ios/domain/entities/stories_viewers.dart';
import 'package:igplus_ios/domain/entities/story_viewer.dart';
import 'package:igplus_ios/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igplus_ios/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igplus_ios/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

/// List item representing a single Character with its photo and name.
class StoriesViewersInsightListItem extends StatefulWidget {
  const StoriesViewersInsightListItem({
    required this.storiesTopViewer,
    required this.index,
    Key? key,
  }) : super(key: key);

  final StoriesViewer storiesTopViewer;
  final int index;

  @override
  State<StoriesViewersInsightListItem> createState() => _StoriesViewersInsightListItemState();
}

class _StoriesViewersInsightListItemState extends State<StoriesViewersInsightListItem> {
  // initShowFollowButton
  bool showFollowButton = true;

  @override
  Widget build(BuildContext context) {
    if (widget.storiesTopViewer.following == true) {
      showFollowButton = false;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tileColor: ColorsManager.cardBack,
        leading: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.storiesTopViewer.user.username),
          child: Stack(children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                widget.storiesTopViewer.user.picture,
                errorListener: () => const Icon(
                  FontAwesomeIcons.image,
                  color: ColorsManager.appBack,
                ),
              ),
            ),
            (widget.storiesTopViewer.hasLiked)
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
          onTap: () => _openProfileLinkOnInsta(widget.storiesTopViewer.user.username),
          child: SizedBox(
            height: 40.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(widget.storiesTopViewer.user.username,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                ),
                const SizedBox(height: 4),
                Text(
                  (widget.storiesTopViewer.viewsCount > 1)
                      ? '${widget.storiesTopViewer.viewsCount} stories viewed'
                      : '${widget.storiesTopViewer.viewsCount} story viewed',
                  style: const TextStyle(
                    color: ColorsManager.secondarytextColor,
                    fontSize: 12,
                  ),
                ),
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
                igUserId: widget.storiesTopViewer.user.igUserId,
                showFollow: showFollowButton,
              ),
              const SizedBox(height: 4),
              (widget.storiesTopViewer.followedBy)
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
