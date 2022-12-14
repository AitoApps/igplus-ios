import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/presentation/blocs/paywall/cubit/paywall_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:shimmer/shimmer.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({Key? key}) : super(key: key);

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  late AccountInfo? currentUserInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUserInfo = BlocProvider.of<PaywallCubit>(context).getCachedCurrentUserAccountInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserInfo != null) {
      return Scaffold(
        backgroundColor: ColorsManager.appBack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // image
              const Text("Thank you for your purchase!",
                  style: TextStyle(color: ColorsManager.textColor, fontSize: 30, fontFamily: "Abel")),
              const Text("You are now a premium user.",
                  style: TextStyle(color: ColorsManager.secondarytextColor, fontSize: 20, fontFamily: "Abel")),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      border: const Border.fromBorderSide(BorderSide(color: ColorsManager.goldGradient1, width: 2)),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(currentUserInfo!.picture),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 20,
                    child: Shimmer.fromColors(
                        baseColor: ColorsManager.goldGradient1,
                        highlightColor: ColorsManager.goldGradient2,
                        child: const Icon(
                          FontAwesomeIcons.crown,
                          color: ColorsManager.goldGradient1,
                          size: 25,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black,
                              offset: Offset(0.0, 0.0),
                            ),
                          ],
                        )),
                  )
                ],
              ),
              const SizedBox(height: 60),
              CupertinoButton.filled(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 20.0,
                      ),
                      Text('Return to Home',
                          style: TextStyle(
                            color: ColorsManager.appBack,
                            fontFamily: "Abel",
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0,
                          )),
                    ],
                  ),
                  onPressed: () {
                    GoRouter.of(context).goNamed('home');
                  })
            ],
          ),
        ),
      );
    }
    return Container();
  }
}
