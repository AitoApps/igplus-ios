part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AccountInfo accountInfo;
  final bool isSubscribed;
  final String? message;

  const SettingsLoaded({required this.accountInfo, required this.isSubscribed, this.message});

  @override
  List<Object> get props => [accountInfo, message ?? ""];
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure({required this.message});

  @override
  List<Object> get props => [message];
}
