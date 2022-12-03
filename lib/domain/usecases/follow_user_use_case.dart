import 'package:dartz/dartz.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/ig_headers.dart';
import 'package:igshark/domain/repositories/instagram/instagram_repository.dart';

class FollowUserUseCase {
  final InstagramRepository instagramRepository;
  FollowUserUseCase({required this.instagramRepository});

  // follow user
  Future<Either<Failure, bool>> execute({required String userId, required IgHeaders igHeaders}) async {
    return instagramRepository.followUser(userId: userId, igHeaders: igHeaders);
  }
}
