import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_users_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_users_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/save_stories_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_stories_user_to_local_use_case.dart';

part 'user_stories_state.dart';

class UserStoriesCubit extends Cubit<UserStoriesState> {
  final GetStoriesUsersUseCase getUserStories;
  final GetUserUseCase getUser;
  final GetStoriesUsersFromLocalUseCase getStoriesUsersFromLocal;
  final CacheStoriesUserToLocalUseCase cacheStoriesUsersToLocal;
  final CacheStoriesToLocalUseCase cacheStoriesToLocal;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  UserStoriesCubit({
    required this.getUserStories,
    required this.getUser,
    required this.getStoriesUsersFromLocal,
    required this.cacheStoriesUsersToLocal,
    required this.cacheStoriesToLocal,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(UserStoriesInitial());

  void init() async {
    emit(UserStoriesLoading());

    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      emit(const UserStoriesLoaded(userStories: []));
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;

      // // try to get stories from local
      Either<Failure, List<StoriesUser>?> cachedStoriesUsersList = await getStoriesUsersFromLocal.execute();

      // check if StoriesUser is outdated
      bool isDataOutdated = await checkIfDataOutdated(DataNames.storiesUsers.name);

      if (isDataOutdated || cachedStoriesUsersList.isLeft() || (cachedStoriesUsersList as Right).value == null) {
        // get user stories from instagram
        final failureOrUserStories = await getUserStories.execute(igHeaders: currentUser.igHeaders);
        if (failureOrUserStories.isLeft()) {
          emit(const UserStoriesLoaded(userStories: []));
        } else {
          List<StoriesUser> storiesUsersList = (failureOrUserStories as Right).value;
          // delete duplicate stories user
          storiesUsersList = storiesUsersList.toSet().toList();

          emit(UserStoriesLoaded(userStories: storiesUsersList));

          // cache stories user to local
          cacheStoriesUsersToLocal.execute(storiesUserList: storiesUsersList, boxKey: StoriesUser.boxKey);
          // cache stories list to local
          for (StoriesUser storiesUser in storiesUsersList) {
            cacheStoriesToLocal.execute(
                boxKey: StoriesUser.boxKey, storiesList: storiesUser.stories, ownerId: storiesUser.owner.id);
          }

          // reset IgDataUpdate
          await resetIgDataUpdate(DataNames.storiesUsers.name);
        }
      } else {
        final storiesList = (cachedStoriesUsersList as Right).value;
        emit(UserStoriesLoaded(userStories: storiesList));
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
    const nextUpdateInMinutes = 60;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
