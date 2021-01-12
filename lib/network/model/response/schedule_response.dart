// To parse this JSON data, do
//
//     final scheduleResponse = scheduleResponseFromJson(jsonString);

import 'dart:convert';

ScheduleResponse scheduleResponseFromJson(String str) => ScheduleResponse.fromJson(json.decode(str));

String scheduleResponseToJson(ScheduleResponse data) => json.encode(data.toJson());

class ScheduleResponse {
  ScheduleResponse({
    this.count,
    this.result,
  });

  int count;
  List<Result> result;

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) => ScheduleResponse(
    count: json["count"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Result {
  Result({
    this.id,
    this.minute,
    this.hour,
    this.day,
    this.brightness,
    this.userId,
    this.hardwareId,
    this.v,
  });

  String id;
  String minute;
  String hour;
  String day;
  int brightness;
  String userId;
  String hardwareId;
  int v;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["_id"],
    minute: json["minute"],
    hour: json["hour"],
    day: json["day"],
    brightness: json["brightness"],
    userId: json["userId"],
    hardwareId: json["hardwareId"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "minute": minute,
    "hour": hour,
    "day": day,
    "brightness": brightness,
    "userId": userId,
    "hardwareId": hardwareId,
    "__v": v,
  };
}
