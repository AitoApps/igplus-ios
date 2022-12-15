import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/app/extensions/media_query_values.dart';
import 'package:igshark/presentation/blocs/insight/cubit/insight_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/blocs/settings/cubit/settings_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:igshark/presentation/views/global/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoCardList extends StatelessWidget {
  final List<Map> cards;
  final bool isLoading;
  final double minHeight;
  final String? parentPage;
  const InfoCardList({
    Key? key,
    required this.cards,
    this.isLoading = false,
    this.minHeight = 70.0,
    this.parentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> myCardsList = [];
    for (var card in cards) {
      myCardsList.add(myCard(
        title: card["title"],
        subTitle: card["subTitle"],
        context: context,
        type: card["type"],
        locked: card["locked"],
        isSubscribed: card["isSubscribed"],
        hasLoaded: card["hasLoaded"] ?? true,
      ));
    }
    return Column(
      children: myCardsList,
    );
  }

  Widget myCard({
    required String title,
    String? subTitle,
    required BuildContext context,
    int? style,
    String? type,
    required bool locked,
    required bool isSubscribed,
    required bool hasLoaded,
  }) {
    return BlocBuilder<InsightCubit, InsightState>(
      builder: (context, state) {
        if (hasLoaded == false) {
          return loadingCard(context, title, subTitle, hasLoaded: hasLoaded);
        }
        if (isLoading) {
          return loadingCard(context, title, subTitle);
        } else if (parentPage == "settings" || state is InsightLoaded) {
          return GestureDetector(
            onTap: () async {
              // locked cards
              if (locked && !isSubscribed) {
                GoRouter.of(context).pushNamed('paywall');
              }
              // setting links
              else if (type == "rateUs") {
                String appId = Platform.isIOS ? "id1520000000" : "com.aitoapps.igshark";
                await _openAppStore(appId);
              } else if (type == "mailto") {
                _sendMail(context);
              } else if (type == "resetAppData") {
                await _resetDataAlert(context);
              } else if (type == "restorePurchase") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: ColorsManager.cardBack,
                    content: Text(
                      "Trying to restore purchases...",
                      style: TextStyle(color: ColorsManager.secondarytextColor),
                    ),
                  ),
                );
                await BlocProvider.of<SettingsCubit>(context).restorePurchases();
              } else if (type == "aboutSubscriptions") {
                GoRouter.of(context).goNamed("aboutSubscriptions");
              } else if (type == "termOfUse") {
                GoRouter.of(context).goNamed("termOfUse");
              } else if (type == "privacyPolicy") {
                GoRouter.of(context).goNamed('privacyPolicy');
              }
              // likers and commenters
              else if (type == "mostLikes" ||
                  type == "mostComments" ||
                  type == "mostLikesAndComments" ||
                  type == "likersNotFollow" ||
                  type == "commentersNotFollow" ||
                  type == "leastLikesGiven" ||
                  type == "leastCommentsGiven" ||
                  type == "noLikesOrComments") {
                GoRouter.of(context).go('/home/engagement/$type');
              } else
              // Stories
              if (type == "mostViewedStories") {
                return GoRouter.of(context).go('/home/storiesList/$type');
              } else if (type == "topStoriesViewers" ||
                  type == "viewersNotFollowingYou" ||
                  type == "viewersYouDontFollow") {
                return GoRouter.of(context).go('/home/storiesViewersInsight/$type');
              } else
              // Media
              if (type == "mostPopularMedia" ||
                  type == "mostLikedMedia" ||
                  type == "mostCommentedMedia" ||
                  type == "mostViewedMedia") {
                GoRouter.of(context).go('/home/mediaList/$type');
              } else {
                // no page to show

              }
            },
            child: Card(
              color: ColorsManager.cardBack,
              elevation: 1,
              margin: const EdgeInsets.fromLTRB(8.0, 0.5, 8.0, 0.5),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: context.width - 16, minHeight: minHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.57,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(title, style: const TextStyle(fontSize: 16, color: ColorsManager.textColor)),
                                (subTitle != null)
                                    ? Text(subTitle,
                                        style: const TextStyle(fontSize: 14, color: ColorsManager.secondarytextColor))
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: (locked && !isSubscribed)
                          ? Icon(
                              FontAwesomeIcons.lock,
                              color: ColorsManager.secondarytextColor.withOpacity(0.5),
                              size: 18.0,
                            )
                          : const Icon(FontAwesomeIcons.angleRight, color: ColorsManager.secondarytextColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is InsightInitial) {
          return loadingCard(context, title, subTitle);
        } else if (state is InsightLoading) {
          return loadingCard(context, title, subTitle);
        } else if (state is InsightFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: ColorsManager.downColor)));
        }
        return const Center(child: Text("Unknown state", style: TextStyle(color: ColorsManager.textColor)));
      },
    );
  }

  Card loadingCard(context, title, subTitle, {bool hasLoaded = true}) {
    return Card(
      color: ColorsManager.cardBack,
      elevation: 1,
      margin: const EdgeInsets.fromLTRB(8.0, 0.5, 8.0, 0.5),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 16, minHeight: minHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.57,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, color: ColorsManager.textColor)),
                        (subTitle != null)
                            ? Text(subTitle,
                                style: const TextStyle(fontSize: 14, color: ColorsManager.secondarytextColor))
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: (hasLoaded)
                  ? const LoadingIndicator()
                  : Column(
                      children: const [
                        Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 18.0),
                        SizedBox(height: 2),
                        Text("Try later!", style: TextStyle(color: Colors.red, fontSize: 8.0)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAppStore(String appId) async {
    // appstore
    if (Platform.isIOS) {
      Uri uri = Uri.parse("itms-apps://itunes.apple.com/app/$appId");
      try {
        var rs = await launchUrl(
          uri,
        );
        if (rs == false) {
          var url = 'https://itunes.apple.com/app/$appId';
          Uri uri = Uri.parse(url);
          await launchUrl(
            uri,
          );
        }
      } catch (e) {
        throw 'There was a problem to open the url: https://itunes.apple.com/app/$appId';
      }
    } else if (Platform.isAndroid) {
      Uri uri = Uri.parse("https://play.google.com/store/apps/details?id=$appId");
      try {
        var rs = await launchUrl(
          uri,
        );
        if (rs == false) {
          var url = 'https://play.google.com/store/apps/details?id=$appId';
          Uri uri = Uri.parse(url);
          await launchUrl(
            uri,
          );
        }
      } catch (e) {
        throw 'There was a problem to open the url: https://play.google.com/store/apps/details?id=$appId';
      }
    }
  }

  void _sendMail(context) async {
    final url = Mailto(
      to: [
        'contact@igshark.app',
      ],
      cc: [],
      bcc: [],
      subject: 'Report a bug or suggest a feature',
      body: '',
    );
    try {
      Uri uri = Uri.parse(url.toString());
      await launchUrl(uri);
    } catch (e) {
      throw 'There was a problem to open the url: $url';
    }
  }

  Future<void> _resetDataAlert(context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel", style: TextStyle(color: ColorsManager.primaryColor)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Reset data", style: TextStyle(color: ColorsManager.primaryColor)),
      onPressed: () async {
        await BlocProvider.of<SettingsCubit>(context).resetData();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsManager.cardBack,
      title: const Text("Are you sure you want to reset data?", style: TextStyle(color: ColorsManager.textColor)),
      content: const Text("When you reset data, all your data will be deleted permanently.",
          style: TextStyle(color: ColorsManager.textColor)),
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
