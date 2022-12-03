import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/ig_headers.dart';
import 'package:igshark/domain/usecases/authorize_user.dart';
import 'package:igshark/domain/usecases/creat_user_use_case.dart';
import 'package:igshark/domain/usecases/get_account_info_use_case.dart';
import 'package:igshark/domain/usecases/get_headers_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/sign_up_with_cstom_token_use_case.dart';
import 'package:igshark/domain/usecases/update_user_use_case.dart';

import '../../../../domain/entities/user.dart';

part 'instagram_auth_state.dart';

class InstagramAuthCubit extends Cubit<InstagramAuthState> {
  final GetUserUseCase getUser;
  final CreateUserUseCase createUser;
  final UpdateUserUseCase updateUser;
  final GetAccountInfoUseCase getAccountInfo;
  final GetHeadersUseCase getHeaders;
  final AuthorizeUser authorizeUser;
  final SignUpWithCustomTokenUseCase signUpWithCustomToken;
  InstagramAuthCubit({
    required this.getUser,
    required this.createUser,
    required this.updateUser,
    required this.getAccountInfo,
    required this.getHeaders,
    required this.authorizeUser,
    required this.signUpWithCustomToken,
  }) : super(const InstagramAuthInitial());

// if user is not connected to instagram, redirect to login page
// if user is connected to instagram, get user info and update user info in Firestore
  void init() async {
    emit(InstagramAuthInProgress());
    final failureOrUser = await authorizeUser.execute();
    if (failureOrUser.isLeft()) {
      emit(const InstagramAuthInitial(updateInstagramAccount: false));
    } else {
      final user = (failureOrUser as Right).value;
      // get account info
      final failurOrAccountInfo = await getAccountInfo.execute(igUserId: user.igUserId, igHeaders: user.igHeaders);
      if (failurOrAccountInfo.isLeft()) {
        final Failure failure = (failurOrAccountInfo as Left).value;
        if (failure is InstagramSessionFailure) {
          emit(const InstagramAuthInitial(updateInstagramAccount: true));
        } else {
          emit(const InstagramAuthFailure(message: 'Failed to get account info'));
        }
      } else {
        final accountInfo = (failurOrAccountInfo as Right).value;
        // update user
        final failureOrUser = await updateUser.execute(
          currentUser: user,
          accountInfo: accountInfo,
          igHeaders: user.igHeaders,
        );
        if (failureOrUser.isLeft()) {
          emit(const InstagramAuthFailure(message: 'Failed to update user'));
        } else {
          emit(const InstagramAuthSuccess());
        }
      }
    }
  }

  Future<void> createOrUpdateInstagramInfo({
    required String igUserId,
    required Map<String, dynamic> headers,
  }) async {
    emit(InstagramAuthInProgress());
    // get headers from instagram webview
    final failurOrIgHeaders = await getHeaders.execute(headers: headers);
    if (failurOrIgHeaders.isLeft()) {
      emit(const InstagramAuthFailure(message: 'Failed to get headers'));
    }
    // get account info from instagram using igHeaders
    final IgHeaders igHeaders = (failurOrIgHeaders as Right).value;
    final failurOrAccountInfo = await getAccountInfo.execute(igUserId: igUserId, igHeaders: igHeaders);
    if (failurOrAccountInfo.isLeft()) {
      final Failure failure = (failurOrAccountInfo as Left).value;
      if (failure is InstagramSessionFailure) {
        emit(const InstagramAuthInitial(updateInstagramAccount: true));
      } else {
        emit(const InstagramAuthFailure(message: 'Failed to get account info'));
      }
    } else {
      final AccountInfo accountInfo = (failurOrAccountInfo as Right).value;
      // we have account info, now we need to sign up or sign in with custom token
      final failureOrSignUpSuccess = await signUpWithCustomToken.execute(uid: accountInfo.igUserId);
      if (failureOrSignUpSuccess.isLeft()) {
        emit(const InstagramAuthFailure(message: "Failed to sign up with custom token"));
      } else {
        // get user from Firestore
        final failureOrCurrentUser = await getUser.execute();
        // if user does not exist
        if (failureOrCurrentUser.isLeft()) {
          // create user in Firestore
          final failureOrSuccess = await createUser.execute(accountInfo: accountInfo, igHeaders: igHeaders);
          if (failureOrSuccess.isLeft()) {
            emit(const InstagramAuthFailure(message: 'Failed to create user'));
          } else {
            emit(const InstagramAuthSuccess());
          }
        } else {
          // if user exists, update user
          final User currentUser = (failureOrCurrentUser as Right).value;
          final failureOrUser = await updateUser.execute(
            currentUser: currentUser,
            accountInfo: accountInfo,
            igHeaders: igHeaders,
          );
          if (failureOrUser.isLeft()) {
            emit(const InstagramAuthFailure(message: 'Failed to update user'));
          } else {
            emit(const InstagramAuthSuccess());
          }
        }
      }
    }
  }

  emitInstagramAuthInitialState() {
    emit(const InstagramAuthInitial());
  }
}
