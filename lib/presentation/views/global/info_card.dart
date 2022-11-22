import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/app/extensions/media_query_values.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/images_stack.dart';
import 'package:intl/intl.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final int count;
  final IconData icon;
  final BuildContext context;
  final int? style;
  final String type;
  final int newFriends;
  final List<String>? imagesStack;
  final bool isSubscribed;
  const InfoCard({
    Key? key,
    required this.title,
    this.subTitle,
    required this.count,
    required this.icon,
    required this.context,
    this.style,
    required this.type,
    required this.newFriends,
    this.imagesStack,
    this.isSubscribed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (style == 1) {
      return GestureDetector(
        onTap: () {
          if (type == "whoAdmiresYou") {
            if (!isSubscribed) {
              GoRouter.of(context).go('/home/paywall');
            } else {
              context.go('/home/whoAdmiresYou');
            }
          } else {
            GoRouter.of(context).go('/home/friendsList/$type');
          }
        },
        child: Stack(children: [
          Card(
            color: ColorsManager.cardBack,
            elevation: 1,
            margin: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: context.width - 23, minHeight: context.height / 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: context.width / 1.1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                                      child: Icon(icon, color: ColorsManager.secondarytextColor, size: 40),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: const TextStyle(fontSize: 16, color: ColorsManager.textColor)),
                                        Text(subTitle ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 14, color: ColorsManager.secondarytextColor)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: imageStack(imageList: imagesStack!, totalCount: count),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          (!isSubscribed)
              ? Positioned(
                  top: 20,
                  right: 20,
                  child: Icon(
                    FontAwesomeIcons.lock,
                    color: ColorsManager.cardIconColor.withOpacity(0.3),
                    size: 20,
                  ))
              : const SizedBox.shrink(),
        ]),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // GoRouter.of(context).goNamed('friendsList');
          GoRouter.of(context).go('/home/friendsList/$type');
        },
        child: Card(
          color: ColorsManager.cardBack,
          elevation: 1,
          margin: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: context.width / 2.3, minHeight: context.height / 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 10),
                      child: Icon(icon, size: 24),
                    ),
                    Row(
                      children: [
                        Text(NumberFormat.compact().format(count),
                            style: const TextStyle(
                                fontSize: 20, color: ColorsManager.textColor, fontWeight: FontWeight.bold)),
                        (newFriends != 0)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon((newFriends > 0) ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                                        size: 14,
                                        color: (newFriends > 0) ? ColorsManager.upColor : ColorsManager.downColor,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 20.0,
                                            color: (newFriends > 0) ? ColorsManager.upColor : ColorsManager.downColor,
                                          ),
                                        ]),
                                    Text(newFriends.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (newFriends > 0) ? ColorsManager.upColor : ColorsManager.downColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
                Text(title, style: const TextStyle(fontSize: 14, color: ColorsManager.secondarytextColor)),
              ],
            ),
          ),
        ),
      );
    }
  }
}
