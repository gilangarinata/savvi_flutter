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
    this.position,
    this.username
  });

  String name;
  String description;
  String id;
  Hardware hardware;
  String user;
  String position;
  String username;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    name: json["name"],
    description: json["description"],
    id: json["_id"],
    hardware: Hardware.fromJson(json["hardware"]),
    user: json["user"],
    position: json["position"],
    username: json["username"]
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "_id": id,
    "hardware": hardware.toJson(),
    "user": user,
    "position" : position,
    "username" : username
  };
}

class Hardware {
  Hardware(
      {this.id,
      this.name,
      this.hardwareId,
      this.brightness,
      this.brightnessSchedule,
      this.active,
      this.lamp,
      this.latitude,
      this.longitude,
      this.photoPath});

  String id;
  String name;
  String hardwareId;
  int brightness;
  int brightnessSchedule;
  bool active;
  bool lamp;
  String latitude;
  String longitude;
  String photoPath;

  factory Hardware.fromJson(Map<String, dynamic> json) => Hardware(
        id: json["_id"],
        name: json["name"],
        hardwareId: json["hardwareId"],
        brightness: json["brightness"] == null ? null : json["brightness"],
        brightnessSchedule:
            json["brightnessSchedule"] == null ? 0 : json["brightnessSchedule"],
        lamp: json["lamp"] == null ? null : json["lamp"],
        active: json["active"] == null ? null : json["active"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        photoPath: json["photoPath"] == null ? null : json["photoPath"],
      );

  Map<String, dynamic> toJson() =>
      {
        "_id": id,
        "name": name,
        "hardwareId": hardwareId,
        "brightness": brightness == null ? null : brightness,
        "brightnessSchedule": brightnessSchedule == null
            ? 0
            : brightnessSchedule,
        "lamp": lamp == null ? null : lamp,
        "active": active == null ? null : active,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "photoPath": photoPath == null ? null : photoPath,
      };
}
