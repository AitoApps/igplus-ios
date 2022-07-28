import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:igplus_ios/domain/usecases/get_new_followers.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockInstagramRepository instagramRepository;
  late GetNewFollowers usecase;
  setUp(() {
    instagramRepository = MockInstagramRepository();
    usecase = GetNewFollowers(
      instagramRepository: instagramRepository,
    );
  });

  final List<Friend> testFriendList = [
    Friend(igUserId: 3222, username: "username", isPrivate: true, picture: "picture"),
  ];

  test('should return a List of new friends', () async {
    // arrange
    when(instagramRepository.getNewFollowers()).thenAnswer((_) async => Right(testFriendList));

    // act
    final result = await usecase.execute();

    // assert
    expect(result, equals(Right(testFriendList)));
  });
}