import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/app/extensions/media_query_values.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';

class InfoCardList extends StatelessWidget {
  final List<Map> cards;
  final bool isLoading;
  final double minHeight;
  final String? parentPage;
  const InfoCardList({Key? key, required this.cards, this.isLoading = false, this.minHeight = 70.0, this.parentPage})
      : super(key: key);

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
  }) {
    return BlocBuilder<MediaListCubit, MediaListState>(
      builder: (context, state) {
        if (parentPage == "settings" || state is MediaListSuccess) {
          return GestureDetector(
            onTap: () {
              if (parentPage == "settings") {
              } else if (locked && !isSubscribed) {
                GoRouter.of(context).pushNamed('paywall');
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
                GoRouter.of(context).go('/home/mediaList/$type');
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
        }
        if (isLoading) {
          return loadingCard(context, title, subTitle);
        } else if (state is MediaListInitial) {
          return loadingCard(context, title, subTitle);
        } else if (state is MediaListLoading) {
          return loadingCard(context, title, subTitle);
        } else if (state is MediaListFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: ColorsManager.downColor)));
        }
        return const Center(child: Text("Unknown state", style: TextStyle(color: ColorsManager.textColor)));
      },
    );
  }

  Card loadingCard(context, title, subTitle) {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LoadingIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
