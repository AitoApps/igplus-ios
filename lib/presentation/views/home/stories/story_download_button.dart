import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/story.dart';
import '../../../blocs/insight/stories_insight/story_viewers/story_download/cubit/story_download_cubit.dart';
import '../../global/loading_indicator.dart';

class DownloadStory extends StatelessWidget {
  const DownloadStory({
    Key? key,
    required this.currentStory,
  }) : super(key: key);

  final Story currentStory;

  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text("Story downloaded To Gallery"),
                content: const Text("Do you want to open it?"),
                // content: Text(widget.currentStory?.mediaUrl.toString() ?? ""),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Open"),
                  ),
                  CupertinoDialogAction(
                    //isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryDownloadCubit, StoryDownLoadState>(listener: ((context, state) {
      if (state is StoryDownLoadSuccess) {
        _showAlertDialog(context);
      }
    }), builder: (context, state) {
      if (state is StoryDownLoadInProgress) {
        return Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
          ),
          child: const LoadingIndicator(),
        );
      }
      return GestureDetector(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
          ),
          child: const Icon(Icons.download_rounded, color: Colors.white),
        ),
        onTap: () {
          context.read<StoryDownloadCubit>().downloadStory(story: currentStory);
          // }
        },
      );
    });
  }
}
