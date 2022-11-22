import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/app/constants/media_constants.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:story_view/story_view.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:igshark/domain/entities/story.dart';
import 'package:igshark/presentation/blocs/home/stories/cubit/stories_cubit.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({Key? key, required this.storyOwner}) : super(key: key);

  final StoryOwner storyOwner;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  final StoryController controller = StoryController();
  @override
  void initState() {
    super.initState();
    context.read<StoriesCubit>().init(storyOwner: widget.storyOwner);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: BlocBuilder<StoriesCubit, StoriesState>(
        builder: (context, state) {
          if (state is StoriesLoaded) {
            List<Story?> stories = state.stories;
            if (stories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Can't find any stories", style: TextStyle(color: ColorsManager.primaryColor)),
                    TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text("Go back", style: TextStyle(color: ColorsManager.primaryColor)),
                    )
                  ],
                ),
              );
            }
            final List<StoryItem> storyItems = stories.map((story) {
              if (story != null && story.mediaType == MediaConstants.TYPE_IMAGE) {
                return StoryItem.pageImage(
                  url: story.mediaUrl,
                  controller: controller,
                  // caption: storyOwner.username,
                  // imageFit: BoxFit.cover,
                );
              } else if (story != null && story.mediaType == MediaConstants.TYPE_VIDEO) {
                return StoryItem.pageVideo(
                  story.mediaUrl,
                  controller: controller,
                  // caption: storyOwner.username,
                  // imageFit: BoxFit.cover,
                );
              } else {
                return StoryItem.text(
                    title: "No Stories for ${state.storyOwner.username}",
                    backgroundColor: const Color.fromARGB(255, 200, 7, 7));
              }
            }).toList();

            return GestureDetector(
                onHorizontalDragEnd: (dragUpdateDetails) {
                  if (dragUpdateDetails.primaryVelocity != null) {
                    if (dragUpdateDetails.primaryVelocity! > 0) {
                      controller.previous();
                    } else if (dragUpdateDetails.primaryVelocity! < 0) {
                      controller.next();
                    }
                  }
                },
                onLongPressDown: (onLongPressDown) {
                  controller.pause();
                },
                onVerticalDragEnd: (dragUpdateDetails) {
                  GoRouter.of(context).pop();
                },
                onLongPress: () {},
                child: Stack(
                  children: <Widget>[
                    StoryView(
                      inline: false,
                      storyItems: storyItems,
                      controller: controller,
                      onComplete: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0.5,
                            1,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.08,
                        right: 16,
                      ),
                      child: _buildProfileView(
                          storyOwner: state.storyOwner,
                          takenAt: (stories[0] != null) ? stories[0]!.takenAt : DateTime.now().millisecondsSinceEpoch,
                          context: context),
                    )
                  ],
                ));
          } else {
            return const Center(child: LoadingIndicator());
          }
        },
      ),
    );
  }
}

Widget _buildProfileView({required StoryOwner storyOwner, required int takenAt, required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      GoRouter.of(context).pop();
    },
    child: SizedBox(
      width: 200.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(FontAwesomeIcons.angleLeft, color: Colors.white, size: 16),
                const SizedBox(width: 6.0),
                CircularCachedImage(picture: storyOwner.profilePicUrl, username: storyOwner.username),
              ],
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    storyOwner.username,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 1.0),
                  Text(
                    timeago.format(DateTime.fromMillisecondsSinceEpoch(takenAt * 1000)),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10.0,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
