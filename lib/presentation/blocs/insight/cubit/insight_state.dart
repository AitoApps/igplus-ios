part of 'insight_cubit.dart';

abstract class InsightState extends Equatable {
  const InsightState();

  @override
  List<Object> get props => [];
}

class InsightInitial extends InsightState {}

class InsightLoading extends InsightState {}

class InsightLoaded extends InsightState {}

class InsightFailure extends InsightState {
  final String message;

  const InsightFailure(this.message);

  @override
  List<Object> get props => [message];
}
