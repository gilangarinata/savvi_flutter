import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/schedule_response.dart';


abstract class ScheduleEvent extends Equatable {}

abstract class ScheduleState extends Equatable {}

class DeleteScheduleEvent extends ScheduleEvent {
  @override
  List<Object> get props => null;
  final String id;

  DeleteScheduleEvent(this.id);
}

class EditScheduledEvent extends ScheduleEvent {
  @override
  List<Object> get props => null;
  final Map<String,String> req;
  final String id;

  EditScheduledEvent(this.req,this.id);
}

class AddScheduleEvent extends ScheduleEvent {
  @override
  List<Object> get props => null;
  final Map<String,String> req;

  AddScheduleEvent(this.req);
}

class FetchSchedule extends ScheduleEvent {
  @override
  List<Object> get props => null;
  final String hardwareId;
  final String userId;

  FetchSchedule(this.hardwareId,this.userId);
}

class ScheduleLoaded extends ScheduleState {
  final List<Result> items;

  ScheduleLoaded({@required this.items});

  @override
  List<Object> get props => [items];
}

class AddScheduleSuccess extends ScheduleState {
  final bool items;

  AddScheduleSuccess({@required this.items});

  @override
  List<Object> get props => [items];
}

class DeleteScheduleSuccess extends ScheduleState {
  final bool items;

  DeleteScheduleSuccess({@required this.items});

  @override
  List<Object> get props => [items];
}

class EditScheduleSuccess extends ScheduleState {
  final bool items;

  EditScheduleSuccess({@required this.items});

  @override
  List<Object> get props => [items];
}


class InitialState extends ScheduleState {
  @override
  List<Object> get props => [];
}

class LoadingState extends ScheduleState {
  @override
  List<Object> get props => [];
}

class DeleteLoadingState extends ScheduleState {
  @override
  List<Object> get props => [];
}

class ErrorState extends ScheduleState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
