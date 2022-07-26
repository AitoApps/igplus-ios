import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/report.dart';
import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/info_card.dart';
import 'package:igshark/presentation/views/global/loading_card.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:igshark/presentation/views/home/profile_card.dart';
import 'package:igshark/presentation/views/home/stats/line-chart.dart';
import 'package:igshark/presentation/views/home/stories/stories_list.dart';

class ReportData extends StatelessWidget {
  const ReportData({
    Key? key,
    required this.accountInfo,
    this.loadingMessage,
    this.report,
    this.isSubscribed = false,
    this.errorMessage,
  }) : super(key: key);

  final Report? report;
  final AccountInfo accountInfo;
  final String? loadingMessage;
  final bool isSubscribed;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // String loadingMessage = "we are loading your data";

    return CupertinoScrollbar(
      thickness: 0,
      child: Stack(alignment: Alignment.center, children: [
        ListView(
          children: <Widget>[
            Padding(
              padding: (loadingMessage != null)
                  ? const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 0.0)
                  : const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
              child: ProfileCard(
                followers: accountInfo.followers,
                followings: accountInfo.followings,
                username: accountInfo.username,
                picture: accountInfo.picture,
                isSubscribed: isSubscribed,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (report != null)
                      ? InfoCard(
                          title: "New Followers",
                          icon: FontAwesomeIcons.userPlus,
                          count: report!.newFollowersCycle,
                          context: context,
                          type: Friend.newFollowersBoxKey,
                          newFriends: report!.newFollowers,
                        )
                      : const LoadingCard(
                          title: "New Followers",
                          icon: FontAwesomeIcons.userPlus,
                        ),
                  (report != null)
                      ? InfoCard(
                          title: "Followers Lost",
                          icon: FontAwesomeIcons.userMinus,
                          count: report!.lostFollowersCycle,
                          context: context,
                          type: Friend.lostFollowersBoxKey,
                          newFriends: report!.lostFollowers,
                        )
                      : const LoadingCard(
                          title: "Followers Lost",
                          icon: FontAwesomeIcons.userMinus,
                        ),
                ],
              ),
            ),
            (report != null && report!.whoAdmiresYou.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: InfoCard(
                      title: "Who Admires You",
                      subTitle: "Find out who's intersted in you",
                      icon: FontAwesomeIcons.heartPulse,
                      count: report!.whoAdmiresYou.length,
                      context: context,
                      style: 1,
                      type: Friend.whoAdmiresYouBoxKey,
                      newFriends: 0,
                      imagesStack: report!.whoAdmiresYou.map((e) => e.user.picture).toList(),
                      isSubscribed: isSubscribed,
                    ),
                  )
                : Container(),
            (report != null) ? LineChartSample(chartData: report!.followersChartData) : Container(),
            const StoriesList(),
            const SectionTitle(title: "Important stats", icon: FontAwesomeIcons.chartSimple),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (report != null)
                      ? InfoCard(
                          title: "Not Following Back",
                          icon: FontAwesomeIcons.userSlash,
                          count: report!.notFollowingBackCycle,
                          context: context,
                          type: Friend.notFollowingBackBoxKey,
                          newFriends: report!.notFollowingBack,
                        )
                      : const LoadingCard(
                          title: "Not Following Back",
                          icon: FontAwesomeIcons.userSlash,
                        ),
                  (report != null)
                      ? InfoCard(
                          title: "You don't follow back",
                          icon: FontAwesomeIcons.userInjured,
                          count: report!.youDontFollowBackCycle,
                          context: context,
                          type: Friend.youDontFollowBackBoxKey,
                          newFriends: report!.youDontFollowBack,
                        )
                      : const LoadingCard(
                          title: "You don't Follow Back",
                          icon: FontAwesomeIcons.userInjured,
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (report != null)
                      ? InfoCard(
                          title: "Mutual Followings",
                          icon: FontAwesomeIcons.userGroup,
                          count: report!.mutualFollowingsCycle,
                          context: context,
                          type: Friend.mutualFollowingsBoxKey,
                          newFriends: report!.mutualFollowings,
                        )
                      : const LoadingCard(
                          title: "Mutual Followings",
                          icon: FontAwesomeIcons.userGroup,
                        ),
                  (report != null)
                      ? InfoCard(
                          title: "You Have Unfollowed",
                          icon: FontAwesomeIcons.usersSlash,
                          count: report!.youHaveUnfollowedCycle,
                          context: context,
                          type: Friend.youHaveUnfollowedBoxKey,
                          newFriends: report!.youHaveUnfollowed,
                        )
                      : const LoadingCard(
                          title: "You Have Unfollowed",
                          icon: FontAwesomeIcons.usersSlash,
                        ),
                ],
              ),
            ),
          ],
        ),
        (loadingMessage != null)
            ? Positioned(
                top: 1.0,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      color: ColorsManager.appBack.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    margin: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: Center(
                      child: Text(
                        loadingMessage!,
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: ColorsManager.cardText,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : (errorMessage != null && errorMessage != "")
                ? errorMessageWidget(context, errorMessage)
                : const SizedBox.shrink(),
      ]),
    );
  }

  errorMessageWidget(context, errorMessage) {
    return Positioned(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 130.0,
          decoration: BoxDecoration(
            color: ColorsManager.appBack.withOpacity(0.98),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ColorsManager.secondarytextColor.withOpacity(0.7), width: 3.0),
          ),
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          margin: const EdgeInsets.only(top: 2.0, bottom: 2.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    (errorMessage!).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 244, 8, 8),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      if (errorMessage == "No internet connection") {
                        BlocProvider.of<ReportCubit>(context).init();
                      } else if (errorMessage != "") {
                        GoRouter.of(context).goNamed('instagram_login', queryParams: {
                          'updateInstagramAccount': 'true',
                        });
                        BlocProvider.of<ReportCubit>(context).init();
                      } else {
                        BlocProvider.of<ReportCubit>(context).init();
                      }
                    },
                    child: Text((errorMessage == "checkpoint required")
                        ? "Pass checkpoint"
                        : (errorMessage == "No internet connection")
                            ? "Retry"
                            : "Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
