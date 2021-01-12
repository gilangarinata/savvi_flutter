import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/history_response.dart';


abstract class HistoryEvent extends Equatable {}

abstract class HistoryState extends Equatable {}

class GetHistory extends HistoryEvent {
  @override
  List<Object> get props => null;
  final String hardwareId;

  GetHistory(this.hardwareId);
}

class HistoryLoaded extends HistoryState {
  final List<History> items;

  HistoryLoaded({@required this.items});

  @override
  List<Object> get props => [items];
}

class InitialState extends HistoryState {
  @override
  List<Object> get props => [];
}

class LoadingState extends HistoryState {
  @override
  List<Object> get props => [];
}

class DeleteLoadingState extends HistoryState {
  @override
  List<Object> get props => [];
}

class ErrorState extends HistoryState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
