// To parse this JSON data, do
//
//     final userAddDeviceResponse = userAddDeviceResponseFromJson(jsonString);

import 'dart:convert';

UserAddDeviceResponse userAddDeviceResponseFromJson(String str) => UserAddDeviceResponse.fromJson(json.decode(str));

String userAddDeviceResponseToJson(UserAddDeviceResponse data) => json.encode(data.toJson());

class UserAddDeviceResponse {
  UserAddDeviceResponse({
    this.count,
    this.users,
  });

  int count;
  List<User> users;

  factory UserAddDeviceResponse.fromJson(Map<String, dynamic> json) => UserAddDeviceResponse(
    count: json["count"],
    users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class User {
  User({
    this.id,
    this.username,
    this.email,
    this.position,
    this.password,
    this.referal,
    this.referalFrom,
    this.referalSu1,
    this.v,
  });

  String id;
  String username;
  String email;
  String position;
  String password;
  String referal;
  String referalFrom;
  String referalSu1;
  int v;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    username: json["username"],
    email: json["email"],
    position: json["position"],
    password: json["password"],
    referal: json["referal"],
    referalFrom: json["referalFrom"],
    referalSu1: json["referalSU1"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "email": email,
    "position": position,
    "password": password,
    "referal": referal,
    "referalFrom": referalFrom,
    "referalSU1": referalSu1,
    "__v": v,
  };

  static List<User> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => User.fromJson(item)).toList();
  }
}
