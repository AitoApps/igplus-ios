import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';

class RemoveFriendFromLocalUseCase {
  final LocalRepository localRepository;
  RemoveFriendFromLocalUseCase({required this.localRepository});

  Future<void> execute({required Friend friend, required String boxKey}) {
    return localRepository.removeFriend(friend: friend, boxKey: boxKey);
  }
}
