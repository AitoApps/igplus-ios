import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/data/failure.dart';

import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/home/profile_manager.dart';
import 'package:igshark/presentation/views/home/report_data.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool subscriptionIsLoading = false;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ReportCubit>(context).init();
    Purchases.addCustomerInfoUpdateListener((_) => updateCustomerStatus());
    updateCustomerStatus();
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();

    if (mounted) {
      setState(() {
        isSubscribed = customerInfo.entitlements.all['premium']?.isActive ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: appMaterialTheme(),
      home: Scaffold(
        body: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: ColorsManager.appBack,
            leading: (subscriptionIsLoading)
                ? const AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: SizedBox(
                      width: 80.0,
                      height: 4.0,
                      child: LinearProgressIndicator(
                        backgroundColor: ColorsManager.appBack,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.cardBack),
                      ),
                    ),
                  )
                : (!isSubscribed)
                    ? GestureDetector(
                        onTap: () async {
                          // open paywall
                          GoRouter.of(context).goNamed('paywall');
                        },
                        child: Shimmer.fromColors(
                          baseColor: ColorsManager.goldGradient1,
                          highlightColor: ColorsManager.goldGradient2,
                          child: Row(
                            children: const [
                              Icon(
                                FontAwesomeIcons.crown,
                                color: ColorsManager.goldGradient1,
                                size: 14.0,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                "Premium",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
            middle: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                if (state is ReportSuccess || state is ReportAccountInfoLoaded) {
                  final String username;
                  if (state is ReportSuccess) {
                    username = state.accountInfo.username;
                  } else if (state is ReportAccountInfoLoaded) {
                    username = state.accountInfo.username;
                  } else {
                    username = "";
                  }
                  return ProfileManager(username: username);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            trailing: BlocBuilder<ReportCubit, ReportState>(builder: (context, state) {
              return SizedBox(
                  width: 80.0,
                  child: (state is ReportSuccess)
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            onTap: () => context.read<ReportCubit>().init(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text("Refresh",
                                    style: TextStyle(fontSize: 12, color: ColorsManager.secondarytextColor)),
                                SizedBox(width: 6.0),
                                Icon(
                                  FontAwesomeIcons.arrowsRotate,
                                  size: 20.0,
                                  color: ColorsManager.textColor,
                                ),
                              ],
                            ),
                          ),
                        )
                      :
                      // mini loading
                      const AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: SizedBox(
                            width: 80.0,
                            height: 4.0,
                            child: LinearProgressIndicator(
                              backgroundColor: ColorsManager.appBack,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.cardBack),
                            ),
                          ),
                        ));
            }),
          ),
          child: BlocBuilder<ReportCubit, ReportState>(
            builder: (context, state) {
              if (state is ReportInProgress) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(
                        radius: 12.0,
                      ),
                      const SizedBox(height: 20.0),
                      Text(state.loadingMessage, style: const TextStyle(fontSize: 12, color: ColorsManager.textColor)),
                      const Text("This can take a few minutes depending on your account size",
                          style: TextStyle(fontSize: 10, color: ColorsManager.secondarytextColor)),
                    ],
                  ),
                );
              } else if (state is ReportAccountInfoLoaded) {
                return ReportData(
                    accountInfo: state.accountInfo, loadingMessage: state.loadingMessage, isSubscribed: isSubscribed);
              }
              if (state is ReportSuccess) {
                return ReportData(
                  report: state.report,
                  accountInfo: state.accountInfo,
                  isSubscribed: isSubscribed,
                  errorMessage: state.errorMessage,
                );
              } else if (state is ReportFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.failure.message.toUpperCase(), style: const TextStyle(fontSize: 18.0)),
                      const SizedBox(height: 20.0),
                      CupertinoButton(
                        color: ColorsManager.cardBack,
                        onPressed: () {
                          if (state.failure is InstagramSessionFailure) {
                            GoRouter.of(context).goNamed('instagram_login', queryParams: {
                              'updateInstagramAccount': 'true',
                            });
                            context.read<ReportCubit>().init();
                          } else {
                            context.read<ReportCubit>().init();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                  (state.failure is InstagramSessionFailure)
                                      ? (state.failure.message == "checkpoint required")
                                          ? "Checkpoint"
                                          : "Login"
                                      : "Retry",
                                  style: const TextStyle(color: ColorsManager.primaryColor, fontSize: 14.0)),
                            ),
                            const Icon(FontAwesomeIcons.arrowRotateRight,
                                size: 14.0, color: ColorsManager.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ReportAccountChanging) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
