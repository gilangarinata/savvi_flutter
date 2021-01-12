// To parse this JSON data, do
//
//     final deviceResponse = deviceResponseFromJson(jsonString);

import 'dart:convert';

DeviceResponse deviceResponseFromJson(String str) => DeviceResponse.fromJson(json.decode(str));

String deviceResponseToJson(DeviceResponse data) => json.encode(data.toJson());

class DeviceResponse {
  DeviceResponse({
    this.count,
    this.result,
  });

  int count;
  List<Result> result;

  factory DeviceResponse.fromJson(Map<String, dynamic> json) => DeviceResponse(
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
    this.name,
    this.description,
    this.id,
    this.hardware,
    this.user,
  });

  String name;
  String description;
  String id;
  Hardware hardware;
  String user;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    name: json["name"],
    description: json["description"],
    id: json["_id"],
    hardware: Hardware.fromJson(json["hardware"]),
    user: json["user"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "_id": id,
    "hardware": hardware.toJson(),
    "user": user,
  };
}

class Hardware {
  Hardware({
    this.id,
    this.name,
    this.hardwareId,
    this.brightness,
    this.lamp,
  });

  String id;
  String name;
  String hardwareId;
  int brightness;
  bool lamp;

  factory Hardware.fromJson(Map<String, dynamic> json) => Hardware(
    id: json["_id"],
    name: json["name"],
    hardwareId: json["hardwareId"],
    brightness: json["brightness"] == null ? null : json["brightness"],
    lamp: json["lamp"] == null ? null : json["lamp"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "hardwareId": hardwareId,
    "brightness": brightness == null ? null : brightness,
    "lamp": lamp == null ? null : lamp,
  };
}
