import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/cubit/stories_insight_cubit.dart';

part 'insight_state.dart';

class InsightCubit extends Cubit<InsightState> {
  final MediaListCubit mediaListCubit;
  final StoriesInsightCubit storiesInsightCubit;
  InsightCubit({required this.mediaListCubit, required this.storiesInsightCubit}) : super(InsightInitial()) {
    init();
  }

  void init() async {
    emit(InsightLoading());
    await mediaListCubit.init();
    emit(InsightLoaded());
  }
}
