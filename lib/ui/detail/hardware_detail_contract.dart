import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart';


abstract class HardwareDetailEvent extends Equatable {}

abstract class HardwareDetailState extends Equatable {}


class DeleteDeviceImage extends HardwareDetailEvent {
  @override
  List<Object> get props => null;
  final String hardwareId;

  DeleteDeviceImage(this.hardwareId);
}

class UploadImage extends HardwareDetailEvent {
  @override
  List<Object> get props => null;
  final String hardwareId;
  final File image;

  UploadImage(this.hardwareId,this.image);
}

class UpdateBrightness extends HardwareDetailEvent {
  @override
  List<Object> get props => null;
  final String hardwareId;
  final String brightness;

  UpdateBrightness(this.hardwareId,this.brightness);
}

class UpdateLampEvent extends HardwareDetailEvent {
  @override
  List<Object> get props => null;
  final Map<String, String> request;
  final String token;

  UpdateLampEvent(this.request,this.token);
}


class FetchHardware extends HardwareDetailEvent {
  @override
  List<Object> get props => null;
  final String id;
  final String token;

  FetchHardware(this.id,this.token);
}

class BrightnessUpdated extends HardwareDetailState {
  final bool items;

  BrightnessUpdated({@required this.items});

  @override
  List<Object> get props => [items];
}

class UploadImageSuccess extends HardwareDetailState {
  final bool state;

  UploadImageSuccess({@required this.state});

  @override
  List<Object> get props => [state];
}

class UpdateLampSuccess extends HardwareDetailState {
  final bool state;

  UpdateLampSuccess({@required this.state});

  @override
  List<Object> get props => [state];
}

class DeleteImageSuccess extends HardwareDetailState {
  final bool state;

  DeleteImageSuccess({@required this.state});

  @override
  List<Object> get props => [state];
}


class HardwareLoaded extends HardwareDetailState {
  final Result items;

  HardwareLoaded({@required this.items});

  @override
  List<Object> get props => [items];
}

class InitialState extends HardwareDetailState {
  @override
  List<Object> get props => [];
}

class LoadingState extends HardwareDetailState {
  @override
  List<Object> get props => [];
}

class UploadLoadingState extends HardwareDetailState {
  @override
  List<Object> get props => [];
}

class DeleteImageLoading extends HardwareDetailState {
  @override
  List<Object> get props => [];
}

class ErrorState extends HardwareDetailState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
