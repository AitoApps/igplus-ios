import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/stories_user.dart';

import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/circular_cached_image.dart';

class StoryCard extends StatelessWidget {
  final StoriesUser userStory;
  const StoryCard({
    Key? key,
    required this.userStory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go('/home/storiesView', extra: userStory.owner);
      },
      child: SizedBox(
        width: 76.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70.00,
                height: 70.00,
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 133, 16, 154),
                        Color.fromARGB(255, 203, 27, 86),
                        Color.fromARGB(255, 159, 24, 69),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(35.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircularCachedImage(
                      picture: userStory.owner.profilePicUrl,
                      username: userStory.owner.username,
                      itemRadius: 56.0,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Text(userStory.owner.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: ColorsManager.secondarytextColor, fontSize: 10.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
