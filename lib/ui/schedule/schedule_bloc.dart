import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/schedule_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/schedule_repository.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_contract.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleRepository repository;

  ScheduleBloc(this.repository) : super(null);

  @override
  ScheduleState get initialState => InitialState();

  @override
  Stream<ScheduleState> mapEventToState(ScheduleEvent event) async* {
    if (event is FetchSchedule) {
      try {
        List<Result> items = await repository.getSchedule(event.userId,event.hardwareId);
        yield ScheduleLoaded(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if (event is AddScheduleEvent) {
      yield LoadingState();
      try {
        bool items = await repository.addSchedule(event.req);
        yield AddScheduleSuccess(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if (event is EditScheduledEvent) {
      yield LoadingState();
      try {
        bool items = await repository.editSchedule(event.req, event.id);
        yield EditScheduleSuccess(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    } else if (event is DeleteScheduleEvent) {
      yield DeleteLoadingState();
      try {
        bool items = await repository.deleteSchedule(event.id);
        yield DeleteScheduleSuccess(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
