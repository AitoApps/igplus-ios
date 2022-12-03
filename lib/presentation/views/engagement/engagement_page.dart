import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_commeters/cubit/media_commenters_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
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
    loadLikesAndComments(context);
    List<Map> bestFollowers = [
      {
        "title": "Most Likes",
        "context": context,
        "type": "mostLikes",
        "locked": false,
        "isSubscribed": isSubscribed,
      },
      {
        "title": "Most Comments",
        "context": context,
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
                isLoading = false;
              } else {
                isLoading = true;
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

  loadLikesAndComments(context) async {
    BlocProvider.of<EngagementCubit>(context).setEngagmentState(EngagementLoading());
    // initialize media data
    await BlocProvider.of<MediaListCubit>(context).init();
    // get likers data
    await BlocProvider.of<MediaLikersCubit>(context).init(boxKey: MediaLiker.boxKey, pageKey: 0, pageSize: 15);
    // wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    // get commenters data
    await BlocProvider.of<MediaCommentersCubit>(context).init(boxKey: MediaCommenter.boxKey, pageKey: 0, pageSize: 15);

    BlocProvider.of<EngagementCubit>(context).setEngagmentState(EngagementLoaded());
  }
}
