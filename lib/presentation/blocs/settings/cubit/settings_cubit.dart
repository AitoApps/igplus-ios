import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/usecases/get_account_info_from_local_use_case.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetAccountInfoFromLocalUseCase getAccountInfoFromLocalUseCase;
  SettingsCubit({required this.getAccountInfoFromLocalUseCase}) : super(SettingsInitial()) {
    initSettings();
  }

  AccountInfo? accountInfo;
  bool isSubscribed = false;

  initSettings() {
    Purchases.addCustomerInfoUpdateListener((_) => updateCustomerStatus());
    updateCustomerStatus();
    emit(SettingsLoading());
    // get user data from local

    AccountInfo? accountInfo = getAccountInfoFromLocal();

    if (accountInfo != null) {
      emit(SettingsLoaded(accountInfo: accountInfo, isSubscribed: isSubscribed));
    } else {
      emit(const SettingsFailure(message: 'Error while loading settings'));
    }
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    isSubscribed = customerInfo.entitlements.all['premium']?.isActive ?? false;
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

  // restore purchase
  Future<void> restorePurchases() async {
    AccountInfo? accountInfo = getAccountInfoFromLocal();
    if (accountInfo != null) {
      try {
        final customerInfo = await Purchases.restorePurchases();
        if (customerInfo.entitlements.all["premium"]!.isActive) {
          String message = 'Your purchase was successful restored. Thank you for your support!';
          emit(SettingsLoaded(
            accountInfo: accountInfo,
            isSubscribed: isSubscribed,
            message: message,
          ));
        } else {
          String message = 'You have no purchase to restored.';
          emit(SettingsLoaded(
            accountInfo: accountInfo,
            isSubscribed: isSubscribed,
            message: message,
          ));
        }
        // emit(SubscriptionLoaded(subscriptionPack));
      } catch (e) {
        String message = 'Error occured wail trying to restored your purchase. try again later.';
        emit(SettingsLoaded(
          accountInfo: accountInfo,
          isSubscribed: isSubscribed,
          message: message,
        ));
      }
    } else {
      emit(const SettingsFailure(message: 'Error while loading settings'));
    }
  }
}
