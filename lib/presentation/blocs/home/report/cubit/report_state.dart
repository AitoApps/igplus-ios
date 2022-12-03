part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportInProgress extends ReportState {
  final String loadingMessage;
  const ReportInProgress({this.loadingMessage = 'Loading...'});

  @override
  List<Object> get props => [loadingMessage];
}

class ReportSuccess extends ReportState {
  final Report report;
  final AccountInfo accountInfo;
  final String? errorMessage;
  const ReportSuccess({required this.report, required this.accountInfo, this.errorMessage});

  @override
  List<Object> get props => [report, accountInfo, errorMessage ?? ""];
}

class ReportAccountChanging extends ReportState {}

class ReportAccountInfoLoaded extends ReportState {
  final AccountInfo accountInfo;
  final String loadingMessage;
  const ReportAccountInfoLoaded({required this.accountInfo, this.loadingMessage = 'Loading...'});
  @override
  List<Object> get props => [accountInfo, loadingMessage];
}

class ReportFailure extends ReportState {
  final String message;
  final Failure failure;

  const ReportFailure({required this.message, required this.failure});
  @override
  List<Object> get props => [message, failure];
}
