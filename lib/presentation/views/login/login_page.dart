import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/blocs/login/cubit/instagram_auth_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool sessionExpired = false;
  @override
  void initState() {
    super.initState();
    context.read<InstagramAuthCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CupertinoPageScaffold(
          backgroundColor: ColorsManager.appBack,
          child: BlocConsumer<InstagramAuthCubit, InstagramAuthState>(
            listener: (context, state) {
              if (state is InstagramAuthSuccess) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
              if (state is InstagramAuthFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                // sessionExpired = true;
                // context.read<InstagramAuthCubit>().emitInstagramAuthInitialState();
              }
            },
            builder: (context, state) {
              print("Login state: $state");
              if (state is InstagramAuthInProgress) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if (state is InstagramAuthInitial) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Image.asset(
                          "assets/images/LoginITopImg.png",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Instant Analysis of your Instagram Freinds",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CupertinoButton(
                          color: ColorsManager.primaryColor,
                          child: const Text(
                            "Login with Instagram",
                            style: TextStyle(
                              color: ColorsManager.buttonColor2,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            GoRouter.of(context).pushNamed('instagram_login', queryParams: {
                              'updateInstagramAccount': state.updateInstagramAccount ? 'true' : 'false'
                            });
                          }),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "InstaTop V1.0 | Developed by @AitoApps",
                        style: TextStyle(
                          color: ColorsManager.secondarytextColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (state is InstagramAuthSuccess) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (state is InstagramAuthFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      TextButton(
                        onPressed: () {
                          context.read<InstagramAuthCubit>().init();
                        },
                        child: const Text("Retry", style: TextStyle(color: ColorsManager.primaryColor)),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: Text('Unknown state', style: TextStyle(color: ColorsManager.secondarytextColor)),
              );
            },
          ),
        ),
      ),
    );
  }
}
