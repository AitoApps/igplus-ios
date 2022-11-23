import 'package:flutter/material.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';

class AboutSubscriptions extends StatelessWidget {
  const AboutSubscriptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: appMaterialTheme(),
      home: Scaffold(
        backgroundColor: ColorsManager.appBack,
        appBar: AppBar(
          backgroundColor: ColorsManager.appBack,
          title: const Text('About Subscriptions '),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                h1Title("About Subscriptions"),
                subTitle("Last updated: 2022-11-22"),
                const SizedBox(height: 20.0),
                h2Title("Information about the auto-renewable nature of the Premium Subscription "),
                const SizedBox(height: 4.0),
                paragraphe("- To use premium IGShark, you should subscribe to our service. "),
                paragraphe(
                    "- Subscription periods are 1 month / 6 months and 12 months. Every 1 month / 6 months or 12 months your subscription renews."),
                paragraphe(
                    "- 1 month subscription price is \$4.99. 6 Months Subscription price is \$14.99. 1 year price is \$19.99."),
                paragraphe("- Payment will be charged to your iTunes Account at confirmation of purchase"),
                paragraphe(
                    "- Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period"),
                paragraphe(
                    "- Account will be charged for renewal within 24-hours prior to the end of the current period."),
                paragraphe(
                    "- Any unused portion of a free trial period will be forfeited when the user purchases a subscription to that publication"),
                paragraphe(" - You can cancel your subscription via this url: httpslasupp_atap_ple.com/en-us/HT202039"),
                paragraphe("- By using Ig Followers, you accept our Terms of use and Private policy."),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget h1Title(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: ColorsManager.primaryColor,
          fontSize: 24.0,
          fontFamily: 'Abel',
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget h2Title(text) {
    return Text(
      text,
      style: const TextStyle(
        color: ColorsManager.cardIconColor,
        fontSize: 20.0,
        fontFamily: 'Abel',
        fontStyle: FontStyle.normal,
      ),
      textAlign: TextAlign.left,
    );
  }

  subTitle(text) {
    return Text(
      text,
      style: const TextStyle(
        color: ColorsManager.secondarytextColor,
        fontSize: 12.0,
        fontFamily: 'OpenSans',
        fontStyle: FontStyle.normal,
        wordSpacing: 3.0,
        letterSpacing: 1.0,
        height: 1.5,
      ),
      textAlign: TextAlign.left,
    );
  }

  paragraphe(text) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(
        text,
        style: const TextStyle(
          color: ColorsManager.textColor,
          fontSize: 14.0,
          fontFamily: 'OpenSans',
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
