import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/report.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:igshark/domain/usecases/get_who_admires_you_from_local_use_case.dart';
import 'package:igshark/presentation/blocs/engagement/media_commeters/cubit/media_commenters_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';

part 'engagement_state.dart';

class EngagementCubit extends Cubit<EngagementState> {
  final GetWhoAdmiresYouFromLocalUseCase getWhoAdmiresYouFromLocalUseCase;
  final MediaListCubit mediaListCubit;
  final MediaLikersCubit mediaLikersCubit;
  final MediaCommentersCubit mediaCommentersCubit;
  final LocalRepository localRepository;
  EngagementCubit({
    required this.getWhoAdmiresYouFromLocalUseCase,
    required this.localRepository,
    required this.mediaListCubit,
    required this.mediaLikersCubit,
    required this.mediaCommentersCubit,
  }) : super(EngagementInitial()) {
    init();
  }

  void init() async {
    emit(EngagementLoading());

    // initialize media data
    await mediaListCubit.init();
    // get likers data
    final mediaLikers = await mediaLikersCubit.init(boxKey: MediaLiker.boxKey, pageKey: 0, pageSize: 15);
    // wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    // get commenters data
    final mediaCommenters = await mediaCommentersCubit.init(boxKey: MediaCommenter.boxKey, pageKey: 0, pageSize: 15);
    // get who admires you
    await getWhoAdmiresYou();

    emit(EngagementLoaded(mediaLikersLoaded: mediaLikers != null, mediaCommentersLoaded: mediaCommenters != null));
  }

  Future<void> getWhoAdmiresYou() async {
    Either<Failure, List<LikesAndComments>?> whoAdmiresYouOrFailure =
        await getWhoAdmiresYouFromLocalUseCase.execute(boxKey: LikesAndComments.boxKey);
    if (whoAdmiresYouOrFailure.isRight() && (whoAdmiresYouOrFailure as Right).value != null) {
      List<LikesAndComments> whoAdmiresYouList = (whoAdmiresYouOrFailure as Right).value!;

      // get report from local
      Either<Failure, Report?> reportOrFailure = localRepository.getCachedReport();
      if (reportOrFailure.isRight() && (reportOrFailure as Right).value != null) {
        Report report = (reportOrFailure as Right).value!;
        report.whoAdmiresYou = whoAdmiresYouList;
        // update local report
        await localRepository.cacheReport(report: report);
      }
    }
  }
}
