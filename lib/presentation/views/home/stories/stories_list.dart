import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/presentation/blocs/home/user_stories/cubit/user_stories_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:igshark/presentation/views/global/section_title.dart';
import 'package:igshark/presentation/views/home/stories/story_card.dart';

class StoriesList extends StatefulWidget {
  const StoriesList({Key? key}) : super(key: key);

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  @override
  void initState() {
    super.initState();
    context.read<UserStoriesCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Watch stories anonymously", icon: FontAwesomeIcons.eyeLowVision),
        BlocBuilder<UserStoriesCubit, UserStoriesState>(
          builder: (context, state) {
            if (state is UserStoriesInitial) {
              return Center(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 82.00,
                child: const Center(
                  child: LoadingIndicator(),
                ),
              ));
            } else if (state is UserStoriesLoading) {
              return Center(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 82.00,
                child: const Center(
                  child: LoadingIndicator(),
                ),
              ));
            } else if (state is UserStoriesLoaded) {
              if (state.userStories.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 82.00,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            FontAwesomeIcons.triangleExclamation,
                            color: ColorsManager.secondarytextColor,
                            size: 10.0,
                          ),
                          SizedBox(width: 8.00),
                          Text("No stories available",
                              style: TextStyle(color: ColorsManager.secondarytextColor, fontSize: 10.00)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 82.00,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.userStories.length,
                  itemBuilder: (context, index) {
                    return StoryCard(userStory: state.userStories[index]);
                  },
                ),
              );
            } else {
              return const Center(child: Text("Error loading stories..."));
            }
          },
        ),
      ],
    );
  }
}
