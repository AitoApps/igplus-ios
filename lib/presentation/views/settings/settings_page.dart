import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/info_card_list.dart';
import 'package:igshark/presentation/views/global/section_title.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSubscribed = false;
    List<Map> appSettings1 = [
      // {
      //   "title": "Likes this app? Rate us",
      //   "context": context,
      // },
      // {
      //   "title": "Reset App Data",
      //   "subTitle": "This will reset all the data stored in the app",
      //   "context": context,
      // },
      {
        "title": "Report a bug or suggest a feature",
        "context": context,
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];

    List<Map> appSettings2 = [
      {
        "title": "Restore Purchase",
        "context": context,
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "About supscriptions",
        "context": context,
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];

    List<Map> appSettings3 = [
      {
        "title": "Term of Use",
        "context": context,
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Privacy Policy",
        "context": context,
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];
    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        thickness: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: ListView(
            children: <Widget>[
              const SectionTitle(
                title: "App settings",
                icon: FontAwesomeIcons.gear,
              ),
              InfoCardList(
                cards: appSettings1,
              ),
              const SizedBox(
                height: 8,
              ),
              InfoCardList(
                cards: appSettings2,
              ),
              const SizedBox(
                height: 8,
              ),
              InfoCardList(
                cards: appSettings3,
              ),
              const Divider(
                height: 10,
                color: ColorsManager.cardBack,
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CupertinoButton(
                    color: ColorsManager.buttonColor2,
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: ColorsManager.textColor,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      GoRouter.of(context).pushNamed('instagram_login');
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
