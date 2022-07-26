import 'package:flutter/cupertino.dart';
import 'package:igplus_ios/presentation/resources/colors_manager.dart';
import 'package:igplus_ios/presentation/views/engagement/engagement_page.dart';
import 'package:igplus_ios/presentation/views/home/home_page.dart';
import 'package:igplus_ios/presentation/views/insghit/insight_page.dart';
import 'package:igplus_ios/presentation/views/settings/settings_page.dart';

class TabPage extends StatelessWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          inactiveColor: ColorsManager.secondarytextColor,
          backgroundColor: ColorsManager.appBack,
          currentIndex: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.graph_square), label: 'Insights'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart_circle), label: 'Engagement'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'settings'),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(builder: (context) => const HomePage());

            case 1:
              return CupertinoTabView(builder: (context) => const InsightPage());

            case 2:
              return CupertinoTabView(builder: (context) => const EngagementPage());

            case 3:
              return CupertinoTabView(builder: (context) => const SettingPage());
            default:
              return CupertinoTabView(builder: (context) => const HomePage());
          }
        });
  }
}