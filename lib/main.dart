import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:igplus_ios/app/app.dart';
import 'package:igplus_ios/app/bloc/app_bloc.dart';
import 'package:igplus_ios/domain/entities/account_info.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:igplus_ios/domain/entities/media.dart';
import 'package:igplus_ios/domain/entities/report.dart';
import 'package:igplus_ios/domain/entities/stories_user.dart';
import 'package:igplus_ios/domain/entities/story.dart';
import 'package:igplus_ios/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igplus_ios/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igplus_ios/presentation/blocs/insight/stories_insight/cubit/stories_insight_cubit.dart';
import 'package:igplus_ios/presentation/blocs/login/cubit/instagram_auth_cubit.dart';
import 'package:igplus_ios/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igplus_ios/presentation/blocs/home/stories/cubit/stories_cubit.dart';
import 'package:igplus_ios/presentation/blocs/home/user_stories/cubit/user_stories_cubit.dart';
import 'app/bloc_observer.dart';
import 'app/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAuth.instance.signInAnonymously();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(FriendAdapter());
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(ChartDataAdapter());
  Hive.registerAdapter(MediaAdapter());
  Hive.registerAdapter(AccountInfoAdapter());
  Hive.registerAdapter(StoryAdapter());
  Hive.registerAdapter(StoryOwnerAdapter());
  Hive.registerAdapter(StoriesUserAdapter());

  // loading the <key,values> pair from the local storage into memory
  try {
    // friends boxes
    await Hive.openBox<Friend>(Friend.followersBoxKey);
    await Hive.openBox<Friend>(Friend.followingsBoxKey);
    await Hive.openBox<Friend>(Friend.newFollowersBoxKey);
    await Hive.openBox<Friend>(Friend.lostFollowersBoxKey);
    await Hive.openBox<Friend>(Friend.whoAdmiresYouBoxKey);
    await Hive.openBox<Friend>(Friend.notFollowingBackBoxKey);
    await Hive.openBox<Friend>(Friend.youDontFollowBackBoxKey);
    await Hive.openBox<Friend>(Friend.youHaveUnfollowedBoxKey);
    await Hive.openBox<Friend>(Friend.mutualFollowingsBoxKey);
    await Hive.openBox<Friend>(Friend.newStoryViewersBoxKey);
    // report box
    await Hive.openBox<Report>(Report.boxKey);
    // media box
    await Hive.openBox<Media>(Media.boxKey);
    // account info box
    await Hive.openBox<AccountInfo>(AccountInfo.boxKey);
    // stories user
    await Hive.openBox<StoriesUser>(StoriesUser.boxKey);
  } catch (e) {
    debugPrint(e.toString());
  }

  await di.init();
  Bloc.observer = AppBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InstagramAuthCubit>(
          create: (_) => di.sl<InstagramAuthCubit>(),
        ),
        BlocProvider<ReportCubit>(create: (_) => di.sl<ReportCubit>()),
        BlocProvider<FriendsListCubit>(create: (_) => di.sl<FriendsListCubit>()),
        BlocProvider<MediaListCubit>(create: (_) => di.sl<MediaListCubit>()),
        BlocProvider<UserStoriesCubit>(create: (_) => di.sl<UserStoriesCubit>()),
        BlocProvider<StoriesCubit>(create: (_) => di.sl<StoriesCubit>()),
        BlocProvider<StoriesListCubit>(create: (_) => di.sl<StoriesListCubit>()),
        BlocProvider<AppBloc>(create: (_) => di.sl<AppBloc>()),
      ],
      child: const App(),
    ),
  );
}
