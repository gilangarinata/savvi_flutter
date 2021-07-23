// To parse this JSON data, do
//
//     final hardwareResponse = hardwareResponseFromJson(jsonString);

import 'dart:convert';

import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';

HardwareResponse hardwareResponseFromJson(String str) => HardwareResponse.fromJson(json.decode(str));

String hardwareResponseToJson(HardwareResponse data) => json.encode(data.toJson());

class HardwareResponse {
  HardwareResponse({
    this.result,
  });

  Result result;

  factory HardwareResponse.fromJson(Map<String, dynamic> json) => HardwareResponse(
    result: Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "result": result.toJson(),
  };
}

class Result {
  Result({
    this.id,
    this.capacity,
    this.chargingTime,
    this.dischargingTime,
    this.betteryHealth,
    this.alarm,
    this.photoPath,
    this.name,
    this.longitude,
    this.latitude,
    this.hardwareId,
    this.temperature,
    this.humidity,
    this.lamp,
    this.brightness,
    this.isActive,
    this.lastSeen,
    this.connectedTo
  });

  String id;
  int capacity;
  String chargingTime;
  String dischargingTime;
  int betteryHealth;
  String alarm;
  dynamic photoPath;
  String name;
  String longitude;
  String latitude;
  String hardwareId;
  String temperature;
  String humidity;
  bool lamp;
  int brightness;
  bool isActive;
  String lastSeen;
  String connectedTo;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["_id"],
    capacity: json["capacity"],
    chargingTime: json["chargingTime"],
    dischargingTime: json["dischargingTime"],
    betteryHealth: json["betteryHealth"],
    alarm: json["alarm"],
    photoPath: json["photoPath"],
    name: json["name"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    hardwareId: json["hardwareId"],
    temperature: json["temperature"],
    humidity: json["humidity"],
    lamp: json["lamp"],
    brightness: json["brightness"],
    isActive: json["isActive"],
    lastSeen: json["lastUpdate"],
    connectedTo: json["connectedTo"] == null ? "-" : json["connectedTo"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "capacity": capacity,
    "chargingTime": chargingTime,
    "dischargingTime": dischargingTime,
    "betteryHealth": betteryHealth,
    "alarm": alarm,
    "photoPath": photoPath,
    "name": name,
    "longitude": longitude,
    "latitude": latitude,
    "hardwareId": hardwareId,
    "temperature": temperature,
    "humidity": humidity,
    "lamp": lamp,
    "brightness": brightness,
    "isActive": isActive,
    "lastSeen": lastSeen,
    "connectedTo": connectedTo,
  };
}
