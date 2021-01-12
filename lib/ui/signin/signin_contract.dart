import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signin_response.dart';

abstract class SignInEvent extends Equatable {}

abstract class SignInState extends Equatable {}

class FetchSignIn extends SignInEvent {
  @override
  List<Object> get props => null;
  final Map<String, String> request;

  FetchSignIn(this.request);
}

class LoadedState extends SignInState {
  final SignInResponse items;

  LoadedState({@required this.items});

  @override
  List<Object> get props => [items];
}

class InitialState extends SignInState {
  @override
  List<Object> get props => [];
}

class LoadingState extends SignInState {
  @override
  List<Object> get props => [];
}

class ErrorState extends SignInState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
