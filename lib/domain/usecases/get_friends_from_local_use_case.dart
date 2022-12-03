import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:dartz/dartz.dart';

class GetFriendsFromLocalUseCase {
  final LocalRepository localRepository;
  GetFriendsFromLocalUseCase({required this.localRepository});

  Future<Either<Failure, List<Friend>?>?> execute(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) async {
    return localRepository.getCachedFriendsList(boxKey: boxKey);
  }
}
