import 'dart:convert';

SignInResponse signInResponseFromJson(String str) =>
    SignInResponse.fromJson(json.decode(str));

String signInResponseToJson(SignInResponse data) => json.encode(data.toJson());

class SignInResponse {
  SignInResponse({
    this.message,
    this.token,
    this.userInfo,
  });

  String message;
  String token;
  UserInfo userInfo;

  factory SignInResponse.fromJson(Map<String, dynamic> json) => SignInResponse(
        message: json["message"],
        token: json["token"],
        userInfo: UserInfo.fromJson(json["userInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
        "userInfo": userInfo.toJson(),
      };
}

class UserInfo {
  UserInfo({
    this.id,
    this.username,
    this.email,
    this.position,
    this.referal,
    this.referalFrom
  });

  String id;
  String username;
  String email;
  String position;
  String referal;
  String referalFrom;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["_id"],
        username: json["username"],
        email: json["email"],
        position: json["position"],
        referal: json["referal"],
        referalFrom: json["referalFrom"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "email": email,
        "position": position,
        "referal": referal,
      };
}
