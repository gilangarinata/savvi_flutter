import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/add_device_request.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/add_device.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/user_add_device_response.dart';


abstract class DashboardEvent extends Equatable {}

abstract class DashboardState extends Equatable {}

class FetchUsers extends DashboardEvent {
  @override
  List<Object> get props => null;
  final String position;
  final String referal;

  FetchUsers(this.position,this.referal);
}

class DeleteDevice extends DashboardEvent {
  @override
  List<Object> get props => null;
  final String deviceId;
  final String token;

  DeleteDevice(this.deviceId,this.token);
}

class UpdateLampEvent extends DashboardEvent {
  @override
  List<Object> get props => null;
  final Map<String, String> request;
  final String token;

  UpdateLampEvent(this.request,this.token);
}

class FetchDevice extends DashboardEvent {
  @override
  List<Object> get props => null;
  final String userId;
  final String token;

  FetchDevice(this.userId,this.token);
}

class AddDevice extends DashboardEvent {
  @override
  List<Object> get props => null;
  final Map<String, String> request;
  final String token;

  AddDevice(this.request,this.token);
}

class UpdateLampSuccess extends DashboardState {
  final bool state;

  UpdateLampSuccess({@required this.state});

  @override
  List<Object> get props => [state];
}

class AddDeviceSuccess extends DashboardState {
  final AddDeviceResponse items;

  AddDeviceSuccess({@required this.items});

  @override
  List<Object> get props => [items];
}

class LoadedState extends DashboardState {
  final List<Result> items;

  LoadedState({@required this.items});

  @override
  List<Object> get props => [items];
}

class InitialState extends DashboardState {
  @override
  List<Object> get props => [];
}

class LoadingState extends DashboardState {
  @override
  List<Object> get props => [];
}

class LoadingFetchUserState extends DashboardState {
  @override
  List<Object> get props => [];
}

class LoadedFetchUserState extends DashboardState {
  final List<User> items;

  LoadedFetchUserState(this.items);

  @override
  List<Object> get props => [items];
}

class ErrorState extends DashboardState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
