import 'package:igshark/domain/repositories/local/local_repository.dart';

class RemoveFriendFromLocalUseCase {
  final LocalRepository localRepository;
  RemoveFriendFromLocalUseCase({required this.localRepository});

  Future<void> execute(String friendKey, String boxKey) {
    return localRepository.removeFriend(friendKey: friendKey, boxKey: boxKey);
  }
}
