import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
import 'package:igshark/presentation/views/global/follow_unfollow_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

/// List item representing a single Character with its photo and name.
class FriendListItem extends StatefulWidget {
  const FriendListItem({
    required this.friend,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final Friend friend;
  final int index;
  final String type;

  @override
  State<FriendListItem> createState() => _FriendListItemState();
}

class _FriendListItemState extends State<FriendListItem> {
  // initShowFollowButton
  bool showFollowButton = true;

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'notFollowingBack') {
      showFollowButton = false;
    } else if (widget.type == 'mutualFollowings') {
      showFollowButton = false;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tileColor: ColorsManager.cardBack,
        leading: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.friend.username),
          child: CircularCachedImage(picture: widget.friend.picture, username: widget.friend.username),
        ),
        title: GestureDetector(
          onTap: () => _openProfileLinkOnInsta(widget.friend.username),
          child: SizedBox(
            height: 40.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(widget.friend.username,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: ColorsManager.cardText)),
                ),
                const SizedBox(height: 4),
                Text(timeago.format(widget.friend.createdOn),
                    style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 12)),
              ],
            ),
          ),
        ),
        trailing: FollowUnfollowButton(
          igUserId: widget.friend.igUserId,
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
