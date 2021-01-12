import 'package:bloc/bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signin_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/auth_repository.dart';
import 'package:mylamp_flutter_v4_stable/ui/signin/signin_contract.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  AuthRepository repository;

  SignInBloc(this.repository) : super(null);

  @override
  SignInState get initialState => InitialState();

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is FetchSignIn) {
      yield LoadingState();
      try {
        SignInResponse items = await repository.processSignIn(event.request);
        yield LoadedState(items: items);
      } catch (e) {
        yield ErrorState(message: e.toString());
      }
    }
  }
}
