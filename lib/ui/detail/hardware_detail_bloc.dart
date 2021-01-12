import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_contract.dart';

class HardwareDetailBloc extends Bloc<HardwareDetailEvent, HardwareDetailState> {
  HardwareDetailRepository repository;

  HardwareDetailBloc(this.repository) : super(null);

  @override
  HardwareDetailState get initialState => InitialState();

  @override
  Stream<HardwareDetailState> mapEventToState(HardwareDetailEvent event) async* {
    if (event is FetchHardware) {
      try {
        Result items = await repository.fetchHardware(event.id,event.token);
        yield HardwareLoaded(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if (event is UpdateBrightness) {
      try {
        bool items = await repository.updateBrightness(event.hardwareId,event.brightness);
        yield BrightnessUpdated(items: items);
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
    }else if(event is UploadImage){
      yield UploadLoadingState();
      try {
        bool state = await repository.uploadImage(event.hardwareId, event.image);
        if(state){
          yield UploadImageSuccess(state: true);
        }else{
          yield ErrorState(message: MyStrings.serverFailed);
        }
      }catch (e) {
        yield ErrorState(message: e.toString());
      }
    }else if(event is DeleteDeviceImage){
      yield DeleteImageLoading();
      try {
        bool state = await repository.deleteImage(event.hardwareId);
        yield DeleteImageSuccess(state: state);
      }catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
