import 'package:dartz/dartz.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/ig_headers.dart';
import 'package:igshark/domain/repositories/instagram/instagram_repository.dart';

class UnfollowUserUseCase {
  final InstagramRepository instagramRepository;
  UnfollowUserUseCase({required this.instagramRepository});

  // unfollow user
  Future<Either<Failure, bool>> execute({required String userId, required IgHeaders igHeaders}) async {
    return instagramRepository.unfollowUser(userId: userId, igHeaders: igHeaders);
  }
}
