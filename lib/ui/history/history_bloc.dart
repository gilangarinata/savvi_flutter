import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/history_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/history_repository.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_contract.dart';


class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryRepository repository;

  HistoryBloc(this.repository) : super(null);

  @override
  HistoryState get initialState => InitialState();

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is GetHistory) {
      try {
        List<History> items = await repository.getHistory(event.hardwareId);
        yield HistoryLoaded(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
