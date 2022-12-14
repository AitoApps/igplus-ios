import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/global/info_card_list.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class EngagementPage extends StatefulWidget {
  const EngagementPage({Key? key}) : super(key: key);

  @override
  State<EngagementPage> createState() => _EngagementPageState();
}

class _EngagementPageState extends State<EngagementPage> {
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();

    Purchases.addCustomerInfoUpdateListener((_) => updateCustomerStatus());
    updateCustomerStatus();
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    if (mounted) {
      setState(() {
        isSubscribed = customerInfo.entitlements.all['premium']?.isActive ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map> bestFollowers = [
      {
        "title": "Most Likes",
        "context": context,
        "subTitle": "Freinds with the most likes given",
        "type": "mostLikes",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Most Comments",
        "context": context,
        "subTitle": "Freinds with the most comments given",
        "type": "mostComments",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      // {
      //   "title": "Most Likes & Commented",
      //   "context": context,
      //   "type": "mostLikesAndComments",
      // }
    ];

    List<Map> missedConnections = [
      {
        "title": "Users liked me, but didn't follow",
        "context": context,
        "type": "likersNotFollow",
        "locked": true,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Users commented, but didn't follow",
        "context": context,
        "type": "commentersNotFollow",
        "locked": true,
        "isSubscribed": isSubscribed,
      },
    ];

    List<Map> ghostFollowers = [
      {
        "title": "Least likes given",
        "subTitle": "Find freinds with the least likes given",
        "context": context,
        "type": "leastLikesGiven",
        "locked": true,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Least comments left",
        "subTitle": "Find freinds with the least comments left",
        "context": context,
        "type": "leastCommentsGiven",
        "locked": true,
        "isSubscribed": isSubscribed,
      },
      // {
      //   "title": "No comments, no likes",
      //   "subTitle": "Find freinds with no comments or likes",
      //   "context": context,
      //   "type": "noLikesOrComments",
      // }
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: appMaterialTheme(),
      home: Scaffold(
        body: CupertinoPageScaffold(
          backgroundColor: ColorsManager.appBack,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: ColorsManager.appBack,
            middle: const Text("Engagement", style: TextStyle(color: ColorsManager.textColor)),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: () => context.read<EngagementCubit>().init(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Refresh", style: TextStyle(fontSize: 12, color: ColorsManager.secondarytextColor)),
                    SizedBox(width: 6.0),
                    Icon(
                      FontAwesomeIcons.arrowsRotate,
                      size: 20.0,
                      color: ColorsManager.textColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: CupertinoScrollbar(
            thickness: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: BlocBuilder<EngagementCubit, EngagementState>(
                builder: (context, state) {
                  if (state is EngagementLoading || state is EngagementInitial) {
                    return ListView(
                      children: <Widget>[
                        const SectionTitle(
                          title: "Best Followers",
                          icon: FontAwesomeIcons.usersGear,
                        ),
                        InfoCardList(
                          cards: bestFollowers,
                          isLoading: true,
                          minHeight: 80,
                        ),
                        const SectionTitle(
                          title: "Missed Connections",
                          icon: FontAwesomeIcons.linkSlash,
                        ),
                        InfoCardList(
                          cards: missedConnections,
                          isLoading: true,
                          minHeight: 80,
                        ),
                        const SectionTitle(
                          title: "Ghost Followers",
                          icon: FontAwesomeIcons.ghost,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InfoCardList(
                            cards: ghostFollowers,
                            isLoading: true,
                            minHeight: 80,
                          ),
                        ),
                      ],
                    );
                  } else if (state is EngagementLoaded) {
                    bestFollowers[0]["hasLoaded"] = state.mediaLikersLoaded;
                    bestFollowers[1]["hasLoaded"] = state.mediaCommentersLoaded;
                    return ListView(
                      children: <Widget>[
                        const SectionTitle(
                          title: "Best Followers",
                          icon: FontAwesomeIcons.usersGear,
                        ),
                        InfoCardList(
                          cards: bestFollowers,
                          isLoading: false,
                          minHeight: 80,
                        ),
                        const SectionTitle(
                          title: "Missed Connections",
                          icon: FontAwesomeIcons.linkSlash,
                        ),
                        InfoCardList(
                          cards: missedConnections,
                          isLoading: false,
                          minHeight: 80,
                        ),
                        const SectionTitle(
                          title: "Ghost Followers",
                          icon: FontAwesomeIcons.ghost,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InfoCardList(
                            cards: ghostFollowers,
                            isLoading: false,
                            minHeight: 80,
                          ),
                        ),
                      ],
                    );
                  } else if (state is EngagementFailure) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Instagram Session Expired",
                          style: TextStyle(
                            color: ColorsManager.textColor,
                            fontSize: 20,
                          ),
                        ),
                        CupertinoButton(
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: ColorsManager.secondarytextColor,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            GoRouter.of(context).goNamed('instagram_login', queryParams: {
                              'updateInstagramAccount': 'true',
                            });
                          },
                        )
                      ],
                    );
                  } else {
                    return const LoadingIndicator();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
