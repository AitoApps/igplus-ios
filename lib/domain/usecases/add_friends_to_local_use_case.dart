import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';

class AddFriendToLocalUseCase {
  final LocalRepository localRepository;
  AddFriendToLocalUseCase({required this.localRepository});

  Future<void> execute({required Friend friend, required String boxKey}) {
    return localRepository.addFriend(friend: friend, boxKey: boxKey);
  }
}
