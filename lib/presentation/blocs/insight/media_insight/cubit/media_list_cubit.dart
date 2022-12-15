import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/user.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_media_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_user_feed_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/save_media_to_local_use_case.dart';

part 'media_list_state.dart';

class MediaListCubit extends Cubit<MediaListState> {
  final GetMediaFromLocalUseCase getMediaFromLocal;
  final GetUserFeedUseCase getUserFeed;
  final GetUserUseCase getUser;
  final CacheMediaToLocalUseCase cacheMediaToLocal;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;

  MediaListCubit({
    required this.getMediaFromLocal,
    required this.getUserFeed,
    required this.getUser,
    required this.cacheMediaToLocal,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(MediaListInitial());

  Future<void> init() async {
    emit(MediaListLoading());

    // check if saved media is outdated
    bool isDataOutdated = await checkIfDataOutdated(DataNames.media.name);

    // get media list from local
    final mediaList = await getMediaListFromLocal(
      boxKey: Media.boxKey,
      pageKey: 0,
      pageSize: 1,
    );

    if (mediaList.isEmpty || isDataOutdated) {
      // get media from instagram
      final mediaList = await getMediaListFromInstagram(
        boxKey: Media.boxKey,
        pageKey: 0,
      );

      if (mediaList != null) {
        emit(MediaListSuccess());
        // cache new medai list to local
        cacheMediaToLocal.execute(boxKey: Media.boxKey, mediaList: mediaList);
        // reset IgDataUpdate
        await resetIgDataUpdate(DataNames.media.name);
      } else {
        emit(const MediaListFailure(message: 'Failed to get media list from instagram'));
      }
    } else {
      emit(MediaListSuccess());
    }
  }

  // get user feed from instagram
  Future<List<Media>?> getMediaListFromInstagram(
      {required String boxKey, required int pageKey, String? searchTerm, String? type}) async {
    late User currentUser;
    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return null;
    } else {
      currentUser = (failureOrCurrentUser as Right).value;
    }

    // get media list from instagram and save it to local
    final Either<Failure, List<Media>> userFeedEither =
        await getUserFeed.execute(userId: currentUser.igUserId, igHeaders: currentUser.igHeaders);
    if (userFeedEither.isRight()) {
      final List<Media> mediaList = (userFeedEither as Right).value;
      // cach media on local
      await cacheMediaToLocal.execute(boxKey: Media.boxKey, mediaList: mediaList);
    }
    if (userFeedEither.isLeft()) {
      emit(const MediaListFailure(message: 'Failed to get media'));
      return null;
    } else {
      final media = (userFeedEither as Right).value;
      if (media != null) {
        return media;
      } else {
        return null;
      }
    }
  }

  // get cached media from local
  Future<List<Media>> getMediaListFromLocal(
      {required String boxKey, required int pageKey, required int pageSize, String? searchTerm, String? type}) async {
    final failureOrMedia = await getMediaFromLocal.execute(
        boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm, type: type);
    if (failureOrMedia == null || failureOrMedia.isLeft()) {
      emit(const MediaListFailure(message: 'Failed to get media'));
      return [];
    } else {
      final media = (failureOrMedia as Right).value;
      if (media != null) {
        return media;
      } else {
        return [];
      }
    }
  }

  Future<bool> checkIfDataOutdated(String dataName) async {
    IgDataUpdate igDataUpdate;
    bool isOutdated = false;

    Either<Failure, IgDataUpdate?> failureOrIgDataUpdate = getIgDataUpdateUseCase.execute(dataName: dataName);
    if (failureOrIgDataUpdate.isLeft() || (failureOrIgDataUpdate as Right).value == null) {
      // if data is not in local, set it as outdated
      isOutdated = true;
    } else {
      igDataUpdate = (failureOrIgDataUpdate as Right).value!;
      // check if data is outdated
      if (igDataUpdate.nextUpdateTime.isBefore(DateTime.now())) {
        isOutdated = true;
      } else {
        isOutdated = false;
      }
    }

    return isOutdated;
  }

  // update IgDataUpdate next update time
  Future<void> resetIgDataUpdate(String dataName) async {
    const nextUpdateInMinutes = 60 * 12;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
