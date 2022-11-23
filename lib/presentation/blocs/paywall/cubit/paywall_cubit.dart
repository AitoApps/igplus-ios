import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/usecases/get_account_info_from_local_use_case.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'paywall_state.dart';

class PaywallCubit extends Cubit<PaywallState> {
  final GetAccountInfoFromLocalUseCase getAccountInfoFromLocalUseCase;
  PaywallCubit({required this.getAccountInfoFromLocalUseCase}) : super(PaywallInitial());

  // purchase product
  purchaseProduct(productId) async {
    emit(PaywallLoading());
    CustomerInfo? customerInfo;
    try {
      customerInfo = await Purchases.purchaseProduct(productId);
      // purchase success

    } catch (e) {
      if (e.toString().contains('PURCHASE_CANCELLED')) {
        emit(const PaywallFailure(message: "Purchase was cancelled."));
      } else {
        emit(const PaywallFailure(message: "An unexpected system error occurred while processing this request."));
      }
    }
    if (customerInfo != null && customerInfo.entitlements.all["premium"]!.isActive) {
      emit(PaywallPaymentSuccess());
    } else {
      emit(PaywallLoaded());
    }
  }

  // restore purchase
  Future<void> restorePurchases() async {
    emit(PaywallLoading());
    try {
      final customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.all["premium"]!.isActive) {
        emit(PaywallPaymentSuccess());
      } else {
        emit(PaywallLoaded());
      }
      // emit(SubscriptionLoaded(subscriptionPack));
    } catch (e) {
      emit(PaywallFailure(message: e.toString()));
    }
  }

  AccountInfo? getCachedCurrentUserAccountInfo() {
    // get cached account info from local
    final accountInfoEither = getAccountInfoFromLocalUseCase.execute();
    AccountInfo? cachedAccountInfo = accountInfoEither.fold(
      (failure) => null,
      (accountInfo) => accountInfo,
    );

    return cachedAccountInfo;
  }
}
