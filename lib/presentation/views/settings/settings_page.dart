import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/presentation/blocs/settings/cubit/settings_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
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
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
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
                  children: <Widget>[
                    Container(
                      color: ColorsManager.cardBack,
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10.0),
                                alignment: Alignment.centerLeft,
                                width: 90.0,
                                height: 90.0,
                                decoration: BoxDecoration(
                                  border: Border.fromBorderSide(BorderSide(
                                      color: (isSubscribed)
                                          ? const Color.fromARGB(255, 212, 148, 10)
                                          : const Color.fromARGB(255, 211, 211, 211),
                                      width: 2)),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(accountInfo.picture),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "@${accountInfo.username}",
                                    style: const TextStyle(
                                      color: ColorsManager.textColor,
                                      fontSize: 20.0,
                                      fontFamily: "Abel",
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "ID: ${accountInfo.igUserId}",
                                    style: const TextStyle(
                                      color: ColorsManager.secondarytextColor,
                                      fontSize: 16.0,
                                      fontFamily: "Abel",
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                GoRouter.of(context).pushNamed('instagram_login');
                              },
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
                child: Text(state.message),
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
