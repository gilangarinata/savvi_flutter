// To parse this JSON data, do
//
//     final addDeviceResponse = addDeviceResponseFromJson(jsonString);

import 'dart:convert';

AddDeviceResponse addDeviceResponseFromJson(String str) => AddDeviceResponse.fromJson(json.decode(str));

String addDeviceResponseToJson(AddDeviceResponse data) => json.encode(data.toJson());

class AddDeviceResponse {
  AddDeviceResponse({
    this.message,
    this.createdDevice,
    this.hardwareId,
  });

  String message;
  CreatedDevice createdDevice;
  String hardwareId;

  factory AddDeviceResponse.fromJson(Map<String, dynamic> json) => AddDeviceResponse(
    message: json["message"],
    createdDevice: CreatedDevice.fromJson(json["createdDevice"]),
    hardwareId: json["hardwareId"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "createdDevice": createdDevice.toJson(),
    "hardwareId": hardwareId,
  };
}

class CreatedDevice {
  CreatedDevice({
    this.name,
    this.description,
    this.id,
    this.hardware,
    this.user,
    this.v,
  });

  String name;
  String description;
  String id;
  String hardware;
  String user;
  int v;

  factory CreatedDevice.fromJson(Map<String, dynamic> json) => CreatedDevice(
    name: json["name"],
    description: json["description"],
    id: json["_id"],
    hardware: json["hardware"],
    user: json["user"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "_id": id,
    "hardware": hardware,
    "user": user,
    "__v": v,
  };
}
