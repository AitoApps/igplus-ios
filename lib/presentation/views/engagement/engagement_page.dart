import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/views/global/info_card_list.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class EngagementPage extends StatefulWidget {
  const EngagementPage({Key? key}) : super(key: key);

  @override
  State<EngagementPage> createState() => _EngagementPageState();
}

class _EngagementPageState extends State<EngagementPage> {
  bool isSubscribed = false;
  bool isLoading = false;

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

    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        thickness: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: BlocConsumer<EngagementCubit, EngagementState>(
            listener: (context, state) {
              if (state is EngagementLoaded) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            builder: (context, state) {
              return ListView(
                children: <Widget>[
                  const SectionTitle(
                    title: "Best Followers",
                    icon: FontAwesomeIcons.usersGear,
                  ),
                  InfoCardList(
                    cards: bestFollowers,
                    isLoading: isLoading,
                    minHeight: 80,
                  ),
                  const SectionTitle(
                    title: "Missed Connections",
                    icon: FontAwesomeIcons.linkSlash,
                  ),
                  InfoCardList(
                    cards: missedConnections,
                    isLoading: isLoading,
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
                      isLoading: isLoading,
                      minHeight: 80,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
