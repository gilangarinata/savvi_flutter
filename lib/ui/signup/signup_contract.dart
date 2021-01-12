import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signup_response.dart';

abstract class SignUpEvent extends Equatable {}

abstract class SignUpState extends Equatable {}

class FetchSignUp extends SignUpEvent {
  @override
  List<Object> get props => null;
  final Map<String, String> request;

  FetchSignUp(this.request);
}

class LoadedState extends SignUpState {
  final SignUpResponse items;

  LoadedState({@required this.items});

  @override
  List<Object> get props => [items];
}

class InitialState extends SignUpState {
  @override
  List<Object> get props => [];
}

class LoadingState extends SignUpState {
  @override
  List<Object> get props => [];
}

class ErrorState extends SignUpState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
