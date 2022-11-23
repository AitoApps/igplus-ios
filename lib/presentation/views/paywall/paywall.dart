import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/presentation/blocs/paywall/cubit/paywall_cubit.dart';
import 'package:igshark/presentation/blocs/paywall/subscription/cubit/subscription_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';
import 'package:igshark/presentation/views/paywall/subscription_pack.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shimmer/shimmer.dart';

class Paywall extends StatefulWidget {
  const Paywall({Key? key}) : super(key: key);

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  String? selected;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();

    Purchases.addCustomerInfoUpdateListener((_) => updateCustomerStatus());
    updateCustomerStatus();
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();

    setState(() {
      isSubscribed = customerInfo.entitlements.all['premium']?.isActive ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSubscribed) {
      BlocProvider.of<PaywallCubit>(context).emit(PaywallPaymentSuccess());
    }
    return MaterialApp(
      color: ColorsManager.appBack,
      theme: appMaterialTheme(),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: CupertinoPageScaffold(
            child: SingleChildScrollView(
              child: Stack(children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/backGreenEffect.png'),
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "x",
                                style: TextStyle(
                                  color: ColorsManager.secondarytextColor,
                                  fontSize: 24.0,
                                  fontFamily: 'Abel',
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: 2.0),
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                    color: ColorsManager.secondarytextColor,
                                    fontSize: 14.0,
                                    fontFamily: 'Abel',
                                    fontStyle: FontStyle.normal,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        child: SizedBox(
                          child: Shimmer.fromColors(
                            baseColor: const Color.fromARGB(255, 212, 148, 10),
                            highlightColor: const Color.fromARGB(255, 220, 255, 22),
                            child: const Text(
                              'Upgrade to Premium',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 38.0,
                                fontFamily: 'Abel',
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                        child: Text(
                          "Unlock all features",
                          style: TextStyle(
                            color: ColorsManager.secondarytextColor,
                            fontSize: 24.0,
                            fontFamily: 'Abel',
                            fontStyle: FontStyle.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      feature("Get access to our most exlusive data"),
                      feature("Watch all instagram stories anonymously"),
                      feature("Find out who unfollowed you"),
                      feature("Discover your secret admires"),
                      feature("And more..."),
                      BlocBuilder<SubscriptionCubit, SubscriptionState>(
                        builder: (context, state) {
                          if (state is SubscriptionLoaded) {
                            List<Package> packages = state.packages;
                            List<Widget> subscriptionPacks = [const SizedBox(height: 20)];
                            String currency =
                                getCurrency(packages.first.storeProduct.priceString, packages.first.storeProduct.price);

                            int counter = 0;
                            selected ??= packages[1].storeProduct.identifier;
                            for (var package in packages) {
                              counter++;
                              final product = package.storeProduct;
                              int numberOfMonths = getMonthsNumber(package.identifier);
                              subscriptionPacks.add(
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selected = package.storeProduct.identifier;
                                    });
                                  },
                                  child: SubscriptionPack(
                                    title: '${capitalize(package.packageType.name)} - ${product.priceString}',
                                    saveText: getSaveText(numberOfMonths),
                                    monthlyPrice: '$currency${getmonthlyPrice(numberOfMonths, product.price)}',
                                    productId: product.identifier,
                                    selected: selected ?? packages[1].storeProduct.identifier,
                                    mostPopular: (counter == 2) ? true : false,
                                  ),
                                ),
                              );
                            }
                            return Column(children: subscriptionPacks);
                          } else if (state is SubscriptionFailure) {
                            return Text(state.message);
                          } else if (state is SubscriptionLoading) {
                            final List<Widget> subscriptionPacks = [
                              const SizedBox(height: 20),
                              subscriptionPackPlaceholder(context),
                              subscriptionPackPlaceholder(context),
                              subscriptionPackPlaceholder(context)
                            ];
                            return Column(children: subscriptionPacks);
                          }

                          return const LoadingIndicator();
                        },
                      ),
                      const SizedBox(height: 20),
                      CupertinoButton.filled(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        onPressed: () async {
                          await BlocProvider.of<PaywallCubit>(context).purchaseProduct(selected);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Continue',
                                style: TextStyle(
                                  color: ColorsManager.appBack,
                                  fontSize: 20.0,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.bold,
                                )),
                            Icon(
                              Icons.arrow_right,
                              size: 26.0,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await BlocProvider.of<PaywallCubit>(context).restorePurchases();
                          },
                          child: const Text(
                            "Restore purchases",
                            style: TextStyle(
                              color: ColorsManager.textColor,
                              fontSize: 16.0,
                              fontFamily: 'Abel',
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).goNamed('terms');
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                              child: Text(
                                "Terms of Service",
                                style: TextStyle(
                                  color: ColorsManager.secondarytextColor,
                                  fontSize: 14.0,
                                  fontFamily: 'Abel',
                                  fontStyle: FontStyle.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Divider(
                            color: ColorsManager.secondarytextColor,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).goNamed('privacy');
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: ColorsManager.secondarytextColor,
                                  fontSize: 14.0,
                                  fontFamily: 'Abel',
                                  fontStyle: FontStyle.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Divider(
                            color: ColorsManager.secondarytextColor,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).goNamed('aboutSub');
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                              child: Text(
                                "About subscriptions",
                                style: TextStyle(
                                  color: ColorsManager.secondarytextColor,
                                  fontSize: 14.0,
                                  fontFamily: 'Abel',
                                  fontStyle: FontStyle.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BlocConsumer<PaywallCubit, PaywallState>(
                  listener: (context, state) {
                    if (state is PaywallFailure) {
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
                    }
                    if (state is PaywallPaymentSuccess) {
                      GoRouter.of(context).goNamed('thankyoupage');
                    }
                  },
                  builder: (context, state) {
                    if (state is PaywallLoading) {
                      return Center(
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                              child: LoadingIndicator(
                            width: 40.0,
                            height: 40.0,
                            radius: 14.0,
                          )),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Padding feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(FontAwesomeIcons.circleCheck, color: ColorsManager.primaryColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
            child: Text(
              text,
              style: const TextStyle(
                color: ColorsManager.textColor,
                fontSize: 18.0,
                fontFamily: 'Abel',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String capitalize(String str) => str[0].toUpperCase() + str.substring(1);

  int getMonthsNumber(String identifier) {
    return (identifier.contains('rc_annual'))
        ? 12
        : (identifier.contains('rc_six_month'))
            ? 6
            : (identifier.contains('rc_three_month'))
                ? 3
                : (identifier.contains('rc_two_month'))
                    ? 2
                    : (identifier.contains('rc_monthly'))
                        ? 1
                        : (identifier.contains('rc_lifetime'))
                            ? 0
                            : (identifier.contains('rc_weekly'))
                                ? -1
                                : 1;
  }

  String getSaveText(int numberOfMonths) {
    return (numberOfMonths == 0)
        ? 'Best price'
        : (numberOfMonths == -1)
            ? 'Normal price'
            : (numberOfMonths == 1)
                ? 'Save 10%'
                : (numberOfMonths == 2)
                    ? 'Save 25%'
                    : (numberOfMonths == 3)
                        ? 'Save 40%'
                        : (numberOfMonths == 6)
                            ? 'Save 60%'
                            : (numberOfMonths == 12)
                                ? 'Save 75%'
                                : 'Normal price';
  }

  getmonthlyPrice(int numberOfMonths, double price) {
    String priceToShow = price.toStringAsFixed(2);
    String monthlyPriceString = (numberOfMonths == 0)
        ? 'No more payments'
        : (numberOfMonths == -1)
            ? '$priceToShow/Weekly'
            : '${(price / numberOfMonths).toStringAsFixed(2)}/Monthly';

    return monthlyPriceString;
  }

  String getCurrency(String priceString, double price) {
    String currency = price.toStringAsFixed(2);
    currency = priceString.replaceAll(currency, '');
    return currency;
  }
}
