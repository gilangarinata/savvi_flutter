import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signup_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/auth_repository.dart';
import 'package:mylamp_flutter_v4_stable/ui/signup/signup_contract.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  AuthRepository repository;

  SignUpBloc(this.repository) : super(null);

  @override
  SignUpState get initialState => InitialState();

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is FetchSignUp) {
      yield LoadingState();
      try {
        SignUpResponse items = await repository.processSignUp(event.request);
        yield LoadedState(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
