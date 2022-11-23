import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(String message) : super(message);
}

class InvalidParamsFailure extends Failure {
  const InvalidParamsFailure(String message) : super(message);
}

//  user authentication failures
class UserAuthenticationFailure extends Failure {
  const UserAuthenticationFailure(String message) : super(message);
}

// instagram authentication failures
class InstagramSessionFailure extends Failure {
  const InstagramSessionFailure(String message) : super(message);
}

// settings authentication failures
class SettingsFailure extends Failure {
  const SettingsFailure(String message) : super(message);
}
