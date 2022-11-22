import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:flutter/material.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

/// List item representing a single Character with its photo and name.
class MediaListItem extends StatefulWidget {
  const MediaListItem({
    required this.media,
    required this.index,
    required this.type,
    Key? key,
  }) : super(key: key);

  final Media media;
  final int index;
  final String type;

  @override
  State<MediaListItem> createState() => _MediaListItemState();
}

class _MediaListItemState extends State<MediaListItem> {
  // initShowFollowButton
  bool showFollowButton = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              // _openProfileLinkOnInsta(widget.media.id.toString());
            },
            child: CachedNetworkImage(
              imageUrl: widget.media.url,
              placeholder: (context, url) => const Center(
                child: LoadingIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(
                FontAwesomeIcons.image,
                color: ColorsManager.appBack,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: ColorsManager.appBack.withOpacity(0.5),
            ),
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  (widget.type == "mostLikedMedia")
                      ? FontAwesomeIcons.heart
                      : (widget.type == "mostCommentedMedia")
                          ? FontAwesomeIcons.comment
                          : (widget.type == "mostViewedMedia")
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.groupArrowsRotate,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                    (widget.type == "mostLikedMedia")
                        ? NumberFormat.compact().format(widget.media.likeCount)
                        : (widget.type == "mostCommentedMedia")
                            ? NumberFormat.compact().format(widget.media.commentsCount)
                            : (widget.type == "mostViewedMedia")
                                ? NumberFormat.compact().format(widget.media.viewCount)
                                : NumberFormat.compact().format((widget.media.likeCount + widget.media.commentsCount)),
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
          (widget.type == "mostPopularMedia")
              ? Positioned(
                  bottom: 1.0,
                  left: 1.0,
                  child: Row(
                    children: [
                      mediaCount(icon: FontAwesomeIcons.heart, count: widget.media.likeCount),
                      mediaCount(icon: FontAwesomeIcons.comment, count: widget.media.commentsCount),
                      (widget.media.mediaType == 1)
                          ? mediaCount(icon: FontAwesomeIcons.eye, count: widget.media.viewCount)
                          : const SizedBox.shrink(),
                    ],
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  mediaCount({required IconData icon, required int count}) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorsManager.appBack.withOpacity(0.6),
        ),
        padding: const EdgeInsets.all(2.0),
        margin: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 6,
            ),
            const SizedBox(
              width: 2,
            ),
            Text(NumberFormat.compact().format((count)), style: const TextStyle(color: Colors.white, fontSize: 6)),
          ],
        ),
      ),
    );
  }

  // void _openProfileLinkOnInsta(String mediaId) async {
  //   // open media
  //   var url = 'instagram://media?id=$mediaId';
  //   Uri uri = Uri.parse(url);
  //   try {
  //     var rs = await launchUrl(
  //       uri,
  //     );
  //     // if (rs == false) {
  //     //   var url = 'https://instagram.com/$username';
  //     //   Uri uri = Uri.parse(url);
  //     //   await launchUrl(
  //     //     uri,
  //     //   );
  //     // }
  //   } catch (e) {
  //     throw 'There was a problem to open the url: $url';
  //   }
  // }
}
