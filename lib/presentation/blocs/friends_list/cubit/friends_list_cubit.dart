import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/usecases/add_friends_to_local_use_case.dart';
import 'package:igshark/domain/usecases/follow_user_use_case.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/remove_friends_from_local_use_case%20copy.dart';
import 'package:igshark/domain/usecases/unfollow_user_use_case%20copy.dart';

part 'friends_list_state.dart';

class FriendsListCubit extends Cubit<FriendsListState> {
  final GetFriendsFromLocalUseCase getFriendsFromLocal;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;
  final GetUserUseCase getUser;
  final AddFriendToLocalUseCase addFriendToLocal;
  final RemoveFriendFromLocalUseCase removeFriendFromLocal;
  FriendsListCubit({
    required this.getFriendsFromLocal,
    required this.followUserUseCase,
    required this.getUser,
    required this.unfollowUserUseCase,
    required this.addFriendToLocal,
    required this.removeFriendFromLocal,
  }) : super(FriendsListInitial());

  Future<List<Friend>?> getFriendsList(
      {required String boxKey, required int pageKey, required int pageSize, String? searchTerm}) async {
    final failureOrFriends =
        await getFriendsFromLocal.execute(boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
    if (failureOrFriends == null || failureOrFriends.isLeft()) {
      emit(const FriendsListFailure(message: 'Failed to get friends'));
      return null;
    } else {
      final friends = (failureOrFriends as Right).value;
      if (friends != null) {
        return friends;
      } else {
        return null;
      }
    }
  }

  // follow user
  Future<bool> followUser({required Friend friend, required String boxKey}) async {
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return false;
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;
      final failureOrSuccess =
          await followUserUseCase.execute(userId: friend.igUserId, igHeaders: currentUser.igHeaders);

      if (failureOrSuccess.isLeft()) {
        return false;
      } else {
        // add user to followers list
        addFriendToLocal.execute(friend: friend, boxKey: boxKey);
        return true;
      }
    }
  }

  // unfollow user
  Future<bool> unfollowUser({required Friend friend, required String boxKey}) async {
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return false;
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;
      final failureOrSuccess =
          await unfollowUserUseCase.execute(userId: friend.igUserId, igHeaders: currentUser.igHeaders);

      if (failureOrSuccess.isLeft()) {
        return false;
      } else {
        // remove user from followers list
        removeFriendFromLocal.execute(friend: friend, boxKey: boxKey);
        return true;
      }
    }
  }
}
