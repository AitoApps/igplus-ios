import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/app/extensions/media_query_values.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';

class MediaCardList extends StatelessWidget {
  final List<Map> cards;
  const MediaCardList({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> myCardsList = [];
    for (var card in cards) {
      myCardsList.add(myCard(
        title: card["title"],
        subTitle: card["subTitle"],
        context: context,
        type: card["type"],
      ));
    }
    return Column(
      children: myCardsList,
    );
  }

  Widget myCard({required String title, String? subTitle, required BuildContext context, int? style, String? type}) {
    return BlocBuilder<MediaListCubit, MediaListState>(
      builder: (context, state) {
        if (state is MediaListInitial) {
          return loadingCard(context, title, subTitle);
        } else if (state is MediaListLoading) {
          return loadingCard(context, title, subTitle);
        } else if (state is MediaListFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: ColorsManager.downColor)));
        } else if (state is MediaListSuccess) {
          return GestureDetector(
            onTap: () => GoRouter.of(context).go('/home/mediaList/$type'),
            child: Card(
              color: ColorsManager.cardBack,
              elevation: 1,
              margin: const EdgeInsets.fromLTRB(8.0, 0.5, 8.0, 0.5),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: context.width - 16, minHeight: context.height / 10),
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
                      child: Icon(FontAwesomeIcons.angleRight, color: ColorsManager.secondarytextColor),
                    ),
                  ],
                ),
              ),
            ),
          );
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
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 16, minHeight: MediaQuery.of(context).size.height / 10),
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
