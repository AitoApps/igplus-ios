import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/presentation/blocs/settings/cubit/settings_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/global/info_card_list.dart';
import 'package:igshark/presentation/views/global/logout_alert.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:shimmer/shimmer.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSubscribed = false;
    List<Map> appSettings1 = [
      {
        "title": "Likes this app? Rate us",
        "context": context,
        "type": "rateUs",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Report a bug or suggest a feature",
        "context": context,
        "type": "mailto",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Reset App Data",
        "context": context,
        "type": "resetAppData",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
    ];

    List<Map> appSettings2 = [
      {
        "title": "Restore Purchase",
        "context": context,
        "type": "restorePurchase",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "About supscriptions",
        "context": context,
        "type": "aboutSubscriptions",
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];

    List<Map> appSettings3 = [
      {
        "title": "Term of Use",
        "context": context,
        "type": "termOfUse",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Privacy Policy",
        "context": context,
        "type": "privacyPolicy",
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appMaterialTheme(),
      home: Scaffold(
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ColorsManager.cardBack,
                    content: Text(
                      state.message!,
                      style: const TextStyle(color: ColorsManager.secondarytextColor),
                    ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is SettingsLoaded) {
              AccountInfo accountInfo = state.accountInfo;
              isSubscribed = state.isSubscribed;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    alignment: Alignment.centerLeft,
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      border: Border.fromBorderSide(BorderSide(
                                          color: (isSubscribed) ? ColorsManager.goldGradient1 : ColorsManager.textColor,
                                          width: 2)),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(accountInfo.picture),
                                      ),
                                    ),
                                  ),
                                  if (isSubscribed)
                                    Positioned(
                                      bottom: 15,
                                      right: 15,
                                      child: Shimmer.fromColors(
                                          baseColor: ColorsManager.goldGradient1,
                                          highlightColor: ColorsManager.goldGradient2,
                                          child: const Icon(
                                            FontAwesomeIcons.crown,
                                            color: ColorsManager.goldGradient1,
                                            size: 18,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4.0,
                                                color: Colors.black,
                                                offset: Offset(0.0, 0.0),
                                              ),
                                            ],
                                          )),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "@${accountInfo.username}",
                                    style: const TextStyle(
                                      color: ColorsManager.textColor,
                                      fontSize: 20.0,
                                      fontFamily: "Abel",
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  (isSubscribed)
                                      ? Shimmer.fromColors(
                                          baseColor: ColorsManager.goldGradient1,
                                          highlightColor: ColorsManager.goldGradient2,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.star,
                                                color: ColorsManager.gold,
                                                size: 12.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                "Premium account",
                                                style: TextStyle(
                                                  color: (isSubscribed)
                                                      ? ColorsManager.secondarytextColor
                                                      : ColorsManager.gold,
                                                  fontSize: 12.0,
                                                  fontFamily: "Abel",
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Row(
                                          children: const [
                                            Icon(
                                              FontAwesomeIcons.star,
                                              color: ColorsManager.secondarytextColor,
                                              size: 12.0,
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              "Free account",
                                              style: TextStyle(
                                                color: ColorsManager.secondarytextColor,
                                                fontSize: 12.0,
                                                fontFamily: "Abel",
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.idCard,
                                        color: ColorsManager.secondarytextColor,
                                        size: 12.0,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        accountInfo.igUserId,
                                        style: const TextStyle(
                                          color: ColorsManager.secondarytextColor,
                                          fontSize: 12.0,
                                          fontFamily: "Abel",
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () => logoutAlert(context),
                              child: const Icon(
                                FontAwesomeIcons.rightFromBracket,
                                color: ColorsManager.textColor,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 8.0,
                      color: ColorsManager.cardBack,
                      thickness: 1.0,
                    ),
                    const SectionTitle(
                      title: "App settings",
                      icon: FontAwesomeIcons.gear,
                    ),
                    InfoCardList(
                      cards: appSettings1,
                      minHeight: 60.0,
                      parentPage: "settings",
                      isLoading: false,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    InfoCardList(
                      cards: appSettings2,
                      minHeight: 60.0,
                      parentPage: "settings",
                      isLoading: false,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    InfoCardList(
                      cards: appSettings3,
                      minHeight: 60.0,
                      parentPage: "settings",
                      isLoading: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 8.0),
                      child: Text(
                        "IGShark v0.0.1 - All rights reserved",
                        style: TextStyle(
                          color: ColorsManager.secondarytextColor,
                          fontFamily: "Abel",
                          fontStyle: FontStyle.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is SettingsFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FontAwesomeIcons.exclamationTriangle, color: ColorsManager.secondarytextColor, size: 50),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(state.message, style: const TextStyle(color: ColorsManager.secondarytextColor)),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
