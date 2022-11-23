import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:dartz/dartz.dart';

class GetWhoAdmiresYouFromLocalUseCase {
  final LocalRepository localRepository;
  GetWhoAdmiresYouFromLocalUseCase({required this.localRepository});

  Either<Failure, List<LikesAndComments>?> execute(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final admirers = localRepository.getCachedWhoAdmiresYouList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
      if (admirers.isLeft()) {
        return const Left(InvalidParamsFailure('No media likers found'));
      } else {
        return admirers;
      }
    } catch (e) {
      return const Left(InvalidParamsFailure("GetMediaLikersFromLocalUseCase catch"));
    }
  }
}
