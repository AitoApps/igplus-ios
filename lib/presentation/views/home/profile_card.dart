import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProfileCard extends StatelessWidget {
  final int followers;
  final int followings;
  final String username;
  final String picture;
  final bool isSubscribed;
  const ProfileCard({
    Key? key,
    required this.followers,
    required this.followings,
    required this.username,
    required this.picture,
    this.isSubscribed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
      color: ColorsManager.cardBack,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(NumberFormat.compact().format(followers),
                      style:
                          const TextStyle(fontSize: 20, color: ColorsManager.textColor, fontWeight: FontWeight.bold)),
                ),
                const Text("Followers", style: TextStyle(fontSize: 16, color: ColorsManager.secondarytextColor)),
              ],
            ),
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(BorderSide(
                        color: (isSubscribed) ? ColorsManager.goldGradient1 : Color.fromARGB(255, 211, 211, 211),
                        width: 2)),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(picture),
                    ),
                  ),
                ),
                if (isSubscribed)
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: Shimmer.fromColors(
                        baseColor: ColorsManager.goldGradient1,
                        highlightColor: ColorsManager.goldGradient2,
                        child: const Icon(
                          FontAwesomeIcons.crown,
                          color: ColorsManager.goldGradient1,
                          size: 20,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black,
                              offset: Offset(0.0, 0.0),
                            ),
                          ],
                        )),
                  ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(followings.toString(),
                      style:
                          const TextStyle(fontSize: 20, color: ColorsManager.textColor, fontWeight: FontWeight.bold)),
                ),
                const Text("Following", style: TextStyle(fontSize: 16, color: ColorsManager.secondarytextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
