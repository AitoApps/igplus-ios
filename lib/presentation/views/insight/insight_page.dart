import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/presentation/blocs/insight/cubit/insight_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/global/info_card_list.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({Key? key}) : super(key: key);

  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  bool isSubscribed = false;
  bool isLoading = true;

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
    List<Map> mediaInsigntCards = [
      {
        "title": "Most Popular",
        "subTitle": "Find the most popular posts",
        "context": context,
        "type": "mostPopularMedia",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Most Liked",
        "subTitle": "Find the most liked posts",
        "context": context,
        "type": "mostLikedMedia",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Most Commented",
        "subTitle": "Find the most commented posts",
        "context": context,
        "type": "mostCommentedMedia",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Most Viewed",
        "subTitle": "Find the most viewed videos",
        "context": context,
        "type": "mostViewedMedia",
        "locked": false,
        "isSubscribed": isSubscribed,
      }
    ];

    List<Map> storiesInsigntCards = [
      {
        "title": "Most Viewed",
        "subTitle": "Find the most viewed stories",
        "context": context,
        "type": "mostViewedStories",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Top viewers",
        "subTitle": "Find the top viewers of your stories",
        "context": context,
        "type": "topStoriesViewers",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Not following you",
        "subTitle": "viewers who are not following you",
        "context": context,
        "type": "viewersNotFollowingYou",
        "locked": true,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "You don't follow",
        "subTitle": "Viewers you don't follow",
        "context": context,
        "type": "viewersYouDontFollow",
        "locked": true,
        "isSubscribed": isSubscribed,
      }
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: appMaterialTheme(),
      home: BlocBuilder<InsightCubit, InsightState>(
        builder: (context, state) {
          return Scaffold(
            body: CupertinoPageScaffold(
              backgroundColor: ColorsManager.appBack,
              navigationBar: CupertinoNavigationBar(
                backgroundColor: ColorsManager.appBack,
                middle: const Text("Engagement", style: TextStyle(color: ColorsManager.textColor)),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<InsightCubit>(context).init();
                    },
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
                  child: ListView(
                    children: <Widget>[
                      // const SectionTitle(
                      //   title: "Insights",
                      //   icon: FontAwesomeIcons.chartPie,
                      // ),
                      // InfoCard(
                      //   title: "Who Admires You",
                      //   subTitle: "Find out who's intersted in you",
                      //   icon: FontAwesomeIcons.solidHeart,
                      //   count: 53,
                      //   context: context,
                      //   style: 1,
                      //   type: "whoAdmiresYou",
                      //   newFriends: 0,
                      // ),
                      const SectionTitle(
                        title: "Media insights",
                        icon: FontAwesomeIcons.images,
                      ),
                      InfoCardList(
                        cards: mediaInsigntCards,
                      ),
                      const SectionTitle(
                        title: "Stories insights",
                        icon: FontAwesomeIcons.circleNotch,
                      ),
                      InfoCardList(
                        cards: storiesInsigntCards,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
