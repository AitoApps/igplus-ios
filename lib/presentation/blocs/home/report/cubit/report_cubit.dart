import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/user.dart';
import 'package:igshark/domain/repositories/auth/auth_repository.dart';
import 'package:igshark/domain/usecases/clear_local_data_use_case.dart';
import 'package:igshark/domain/usecases/get_account_info_from_local_use_case.dart';

import 'package:igshark/domain/usecases/get_account_info_use_case.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_user_feed_use_case.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_report_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/get_who_admires_you_from_local_use_case.dart';
import 'package:igshark/domain/usecases/save_account_info_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_media_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/update_report_use_case.dart';

import 'package:igshark/domain/entities/report.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final UpdateReportUseCase updateReport;
  final GetUserUseCase getUser;
  final GetAccountInfoUseCase getAccountInfo;
  final GetFriendsFromLocalUseCase getDataFromLocal;
  final GetReportFromLocalUseCase getReportFromLocal;
  final GetUserFeedUseCase getUserFeed;
  final CacheMediaToLocalUseCase cacheMediaToLocal;
  final GetAccountInfoFromLocalUseCase getAccountInfoFromLocalUseCase;
  final CacheAccountInfoToLocalUseCase cacheAccountInfoToLocalUseCase;
  final ClearAllBoxesUseCase clearAllBoxesUseCase;
  final AuthRepository authRepository;
  final GetWhoAdmiresYouFromLocalUseCase getWhoAdmiresYouFromLocalUseCase;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  late final StreamSubscription authSubscription;
  ReportCubit({
    required this.updateReport,
    required this.getUser,
    required this.getAccountInfo,
    required this.getDataFromLocal,
    required this.getReportFromLocal,
    required this.getUserFeed,
    required this.cacheMediaToLocal,
    required this.getAccountInfoFromLocalUseCase,
    required this.cacheAccountInfoToLocalUseCase,
    required this.clearAllBoxesUseCase,
    required this.authRepository,
    required this.getWhoAdmiresYouFromLocalUseCase,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(ReportInitial()) {
    authSubscription = authRepository.authUser.listen((user) {
      init();
    });
  }

  String errorMessage = "";

  void init() async {
    late AccountInfo accountInfo;
    errorMessage = "";

    // await clearAllBoxesUseCase.execute();
    // await Hive.box<Media>(Media.boxKey).clear();
    // await Hive.box<StoriesUser>(StoriesUser.boxKey).clear();
    // await Hive.box<StoryViewer>(StoryViewer.boxKey).clear();
    // await Hive.box<MediaCommenter>(MediaCommenter.boxKey).clear();
    emit(const ReportInProgress(loadingMessage: "We are loading your data..."));

    // get cached account info from local
    final cachedAccountInfo = getAccountInfoFromLocal();

    // show old account info
    if (cachedAccountInfo != null) {
      emit(ReportAccountInfoLoaded(accountInfo: cachedAccountInfo));
    }

    // check if accountinfo is outdated
    bool isDataOutdated = await checkIfDataOutdated(DataNames.accountInfo.name);

    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      final failure = (failureOrCurrentUser as Left).value;
      emit(ReportFailure(message: 'Failed to get user info', failure: failure));
    } else {
      User currentUser = (failureOrCurrentUser as Right).value;

      // get account info from instagram if data is outdated
      if (isDataOutdated) {
        if (cachedAccountInfo != null) {
          emit(ReportAccountInfoLoaded(
              accountInfo: cachedAccountInfo, loadingMessage: "Updating your account stats..."));
        }
        // get account info from instagram
        final AccountInfo? accountInfoFromInstagram = await getAccountInfoFromInstagram(currentUser);
        if (accountInfoFromInstagram != null) {
          accountInfo = accountInfoFromInstagram;

          // cache new account info to local
          await cacheAccountInfoToLocalUseCase.execute(accountInfo: accountInfo);

          // reset IgDataUpdate
          await resetIgDataUpdate(DataNames.accountInfo.name);

          emit(ReportAccountInfoLoaded(accountInfo: accountInfo, loadingMessage: "New account stats loaded..."));
        } else {
          accountInfo = cachedAccountInfo!;
        }
      } else {
        // keep using cached account info
        accountInfo = cachedAccountInfo!;
      }

      // TODO check if account was changed
      if (currentUser.igUserId != cachedAccountInfo!.igUserId) {
        // clear all boxes if user changed
        await clearAllBoxesUseCase.execute();
      }

      Either<Failure, Report?>? failureOrReport;

      // get report from local
      failureOrReport = await getReportFromLocal.execute();

      if (failureOrReport.isLeft() ||
          ((failureOrReport as Right).value.followers != accountInfo.followers ||
              (failureOrReport as Right).value.followings != accountInfo.followings)) {
        // track progress of data loading from instagram
        if (failureOrReport.isLeft() || (failureOrReport as Right).value == null) {
          int loadedFriends = 0;
          Timer.periodic(const Duration(seconds: 5), (timer) {
            loadedFriends += 191;
            if (loadedFriends < accountInfo.followers) {
              emit(ReportAccountInfoLoaded(
                  accountInfo: accountInfo,
                  loadingMessage: "$loadedFriends of ${accountInfo.followers} Friends Loaded..."));
            } else {
              emit(ReportAccountInfoLoaded(accountInfo: accountInfo, loadingMessage: "Analysing loaded data..."));
              timer.cancel();
            }
          });
        } else {
          emit(ReportAccountInfoLoaded(accountInfo: accountInfo, loadingMessage: "Analysing loaded data..."));
        }

        // update report
        failureOrReport = await updateReport.execute(currentUser: currentUser, accountInfo: accountInfo);

        if (failureOrReport.isLeft()) {
          final failure = (failureOrReport as Left).value;
          emit(ReportFailure(message: 'Failed to update report', failure: failure));
        } else {
          final report = (failureOrReport as Right).value;
          emit(ReportSuccess(report: report, accountInfo: accountInfo));
        }
      } else {
        // get report from local
        final report = (failureOrReport as Right).value;
        if (failureOrReport.isLeft()) {
          final failure = (failureOrReport as Left).value;
          emit(ReportFailure(message: 'Failed to get report from local', failure: failure));
        } else {
          emit(ReportSuccess(
            report: report,
            accountInfo: accountInfo,
            errorMessage: errorMessage,
          ));
        }
      }
    }
  }

  // get cachedAccountInfo from local
  AccountInfo? getAccountInfoFromLocal() {
    Either<Failure, AccountInfo?> accountInfoEither = getAccountInfoFromLocalUseCase.execute();
    AccountInfo? cachedAccountInfo = accountInfoEither.fold(
      (failure) => null,
      (accountInfo) => accountInfo,
    );
    return cachedAccountInfo;
  }

  getAccountInfoFromInstagram(User currentUser) async {
    final failureOrAccountInfo =
        await getAccountInfo.execute(igUserId: currentUser.igUserId, igHeaders: currentUser.igHeaders);
    if (failureOrAccountInfo.isLeft()) {
      final failure = (failureOrAccountInfo as Left).value;
      errorMessage = failure.message;
      emit(ReportFailure(message: 'Failed to get account info', failure: failure));
    } else {
      return (failureOrAccountInfo as Right).value;
    }
  }

  Future<bool> checkIfDataOutdated(String dataName) async {
    IgDataUpdate igDataUpdate;
    bool isOutdated = false;

    Either<Failure, IgDataUpdate?> failureOrIgDataUpdate = getIgDataUpdateUseCase.execute(dataName: dataName);
    if (failureOrIgDataUpdate.isLeft() || (failureOrIgDataUpdate as Right).value == null) {
      // if data is not in local, set it as outdated
      isOutdated = true;
    } else {
      igDataUpdate = (failureOrIgDataUpdate as Right).value!;
      // check if data is outdated
      if (igDataUpdate.nextUpdateTime.isBefore(DateTime.now())) {
        isOutdated = true;
      } else {
        isOutdated = false;
      }
    }

    return isOutdated;
  }

  // update IgDataUpdate next update time
  Future<void> resetIgDataUpdate(String dataName) async {
    late int nextUpdateInMinutes;
    switch (dataName) {
      case "accountInfo":
        nextUpdateInMinutes = 5;
        break;
      case "report":
        nextUpdateInMinutes = 10;
        break;
      default:
        nextUpdateInMinutes = 10;
    }

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
