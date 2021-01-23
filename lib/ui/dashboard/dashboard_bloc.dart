import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/add_device.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/user_add_device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/auth_repository.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardRepository repository;

  DashboardBloc(this.repository) : super(null);

  @override
  DashboardState get initialState => InitialState();

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    if (event is FetchDevice) {
      yield LoadingState();
      try {
        List<Result> items = await repository.fetchDevice(event.userId,event.token);
        yield LoadedState(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if(event is AddDevice){
      yield LoadingState();
      try {
        AddDeviceResponse items = await repository.addDevice(event.request,event.token);
        yield AddDeviceSuccess(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if(event is UpdateLampEvent){
      try {
        bool state = await repository.updateLamp(event.request, event.token);
        if(state){
          yield UpdateLampSuccess(state: true);
        }else{
          yield ErrorState(message: MyStrings.serverFailed);
        }
      }catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if(event is DeleteDevice){
      yield LoadingState();
      try {
        bool state = await repository.deleteDevice(event.deviceId, event.token);
        if(state){
          yield UpdateLampSuccess(state: true);
        }else{
          yield ErrorState(message: MyStrings.serverFailed);
        }
      }catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if(event is FetchUsers){
      yield LoadingFetchUserState();
      try {
        List<User> users = await repository.fetchUsers(event.referal, event.position);
        yield LoadedFetchUserState(users);
      }catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
