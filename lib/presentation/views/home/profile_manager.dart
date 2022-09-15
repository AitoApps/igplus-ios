import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igplus_ios/presentation/resources/colors_manager.dart';

class ProfileManager extends StatelessWidget {
  final String username;
  const ProfileManager({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      decoration: BoxDecoration(
        color: ColorsManager.cardBack,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<int>(
            offset: const Offset(-6, 32),
            color: ColorsManager.cardBack,
            iconSize: 16.0,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                height: 35.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      FontAwesomeIcons.userPen,
                      color: ColorsManager.textColor,
                      size: 14.0,
                    ),
                    SizedBox(width: 10.0),
                    Text("Change username", style: TextStyle(color: ColorsManager.textColor, fontSize: 16)),
                  ],
                ),
              ),
              const PopupMenuDivider(
                height: 10.0,
              ),
              PopupMenuItem(
                value: 2,
                height: 35.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      FontAwesomeIcons.rightFromBracket,
                      color: ColorsManager.textColor,
                      size: 14.0,
                    ),
                    SizedBox(width: 10.0),
                    Text("Lgout", style: TextStyle(color: ColorsManager.textColor, fontSize: 16)),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  color: ColorsManager.secondarytextColor,
                  size: 16.0,
                ),
                const SizedBox(width: 6.0),
                Text(username, style: const TextStyle(fontSize: 14, color: ColorsManager.textColor)),
                const SizedBox(width: 4.0),
                const Icon(FontAwesomeIcons.angleDown, color: ColorsManager.secondarytextColor),
              ],
            ),
          )
        ],
      ),
    );
  }
}