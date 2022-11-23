import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../app/constants/media_constants.dart';
import '../../../../../../../domain/entities/story.dart';

part 'story_download_state.dart';

class StoryDownloadCubit extends Cubit<StoryDownLoadState> {
  StoryDownloadCubit() : super(StoryDownLoadInitial());

  downloadStory({required Story story}) async {
    emit((StoryDownLoadInProgress()));

    final tempDir = await getTemporaryDirectory();

    if (story.mediaType == MediaConstants.TYPE_VIDEO) {
      // random id
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final path = "${tempDir.path}/$id.mp4";
      await Dio().download(story.mediaUrl, path);
      final bool? success = await GallerySaver.saveVideo(path, albumName: "IGPlus");

      if (success == true) {
        emit((StoryDownLoadSuccess(path: path)));
      }
    }

    if (story.mediaType == MediaConstants.TYPE_IMAGE) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final path = "${tempDir.path}/$id.jpg";
      await Dio().download(story.mediaUrl, path);
      final bool? success = await GallerySaver.saveImage(path, albumName: "IGPlus");

      if (success == true) {
        emit((StoryDownLoadSuccess(path: path)));
      }
    }
  }
}
