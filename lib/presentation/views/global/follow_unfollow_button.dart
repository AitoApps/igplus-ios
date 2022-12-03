import 'package:flutter/material.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:provider/provider.dart';

class FollowUnfollowButton extends StatefulWidget {
  final bool showFollow;
  final Friend friend;
  final String boxKey;
  const FollowUnfollowButton({Key? key, required this.showFollow, required this.friend, required this.boxKey})
      : super(key: key);

  @override
  State<FollowUnfollowButton> createState() => _FollowUnfollowButtonState();
}

class _FollowUnfollowButtonState extends State<FollowUnfollowButton> {
  bool isLoading = false;
  String? error;
  bool? showFollow;

  @override
  Widget build(BuildContext context) {
    showFollow ??= widget.showFollow;

    return (error != null)
        ? Text(error!, style: const TextStyle(color: Colors.red, fontSize: 8))
        : (isLoading)
            ? const Padding(
                padding: EdgeInsets.only(right: 30.0, left: 30.0),
                child: LoadingIndicator(),
              )
            : (showFollow!)
                ? followButton(boxKey: widget.boxKey)
                : unfollowButton(boxKey: widget.boxKey);
  }

  Widget followButton({required String boxKey}) {
    return SizedBox(
      width: 76.0,
      height: 25.0,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(ColorsManager.buttonColor1),
        ),
        onPressed: () async {
          // follow user
          setState(() {
            isLoading = true;
          });
          bool followUserRs = await context.read<FriendsListCubit>().followUser(
                friend: widget.friend,
                boxKey: boxKey,
              );
          print("followUserRs: $followUserRs");
          if (followUserRs) {
            if (mounted) {
              setState(() {
                showFollow = false;
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                error = "Error! try again later";
                isLoading = false;
              });
            }
          }
        },
        child: const Text("Follow", style: TextStyle(color: ColorsManager.buttonTextColor1, fontSize: 10.0)),
      ),
    );
  }

  Widget unfollowButton({required String boxKey}) {
    return SizedBox(
      width: 76.0,
      height: 25.0,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(ColorsManager.buttonColor2),
        ),
        onPressed: () async {
          // unfollow user
          setState(() {
            isLoading = true;
          });
          bool followUserRs =
              await context.read<FriendsListCubit>().unfollowUser(friend: widget.friend, boxKey: boxKey);
          print("unfollowUserRs: $followUserRs");
          if (followUserRs) {
            if (mounted) {
              setState(() {
                showFollow = true;
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                error = "Error! try again later";
                isLoading = false;
              });
            }
          }
        },
        child: const Text("Unfollow", style: TextStyle(color: ColorsManager.buttonTextColor2, fontSize: 10.0)),
      ),
    );
  }
}
