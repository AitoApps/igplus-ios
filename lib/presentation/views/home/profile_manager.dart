import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/logout_alert.dart';

class ProfileManager extends StatelessWidget {
  final String username;
  const ProfileManager({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
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
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => changeUsernameAlert(context),
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
                onTap: () => logoutAlert(context),
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
                    Text("Logout", style: TextStyle(color: ColorsManager.textColor, fontSize: 16)),
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
                const Icon(
                  FontAwesomeIcons.angleDown,
                  color: ColorsManager.secondarytextColor,
                  size: 16.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  changeUsernameAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Change it"),
      onPressed: () {
        GoRouter.of(context).pushNamed('instagram_login', queryParams: {'updateInstagramAccount': 'true'});
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsManager.cardBack,
      title: const Text("Are you sure you want to change your account?"),
      content: const Text("When you change your account, all your old account data will be deleted permanently."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
