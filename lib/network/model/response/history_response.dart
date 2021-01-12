// To parse this JSON data, do
//
//     final historyResponse = historyResponseFromJson(jsonString);

import 'dart:convert';

HistoryResponse historyResponseFromJson(String str) => HistoryResponse.fromJson(json.decode(str));

String historyResponseToJson(HistoryResponse data) => json.encode(data.toJson());

class HistoryResponse {
  HistoryResponse({
    this.history,
  });

  List<History> history;

  factory HistoryResponse.fromJson(Map<String, dynamic> json) => HistoryResponse(
    history: List<History>.from(json["history"].map((x) => History.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "history": List<dynamic>.from(history.map((x) => x.toJson())),
  };
}

class History {
  History({
    this.chargeCapacity,
    this.dischargeCapacity,
    this.batteryCapacity,
    this.batteryLife,
    this.id,
    this.date,
    this.hardwareId,
    this.v,
  });

  String chargeCapacity;
  String dischargeCapacity;
  int batteryCapacity;
  int batteryLife;
  String id;
  DateTime date;
  String hardwareId;
  int v;

  factory History.fromJson(Map<String, dynamic> json) => History(
    chargeCapacity: json["chargeCapacity"],
    dischargeCapacity: json["dischargeCapacity"],
    batteryCapacity: json["batteryCapacity"],
    batteryLife: json["batteryLife"],
    id: json["_id"],
    date: DateTime.parse(json["date"]),
    hardwareId: json["hardwareId"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "chargeCapacity": chargeCapacity,
    "dischargeCapacity": dischargeCapacity,
    "batteryCapacity": batteryCapacity,
    "batteryLife": batteryLife,
    "_id": id,
    "date": date.toIso8601String(),
    "hardwareId": hardwareId,
    "__v": v,
  };
}
