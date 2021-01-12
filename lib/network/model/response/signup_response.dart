import 'dart:convert';

SignUpResponse signUpResponseFromJson(String str) =>
    SignUpResponse.fromJson(json.decode(str));

String signUpResponseToJson(SignUpResponse data) => json.encode(data.toJson());

class SignUpResponse {
  SignUpResponse({
    this.message,
    this.userCreated,
  });

  String message;
  UserCreated userCreated;

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
        message: json["message"],
        userCreated: UserCreated.fromJson(json["userCreated"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "userCreated": userCreated.toJson(),
      };
}

class UserCreated {
  UserCreated({
    this.username,
    this.email,
    this.position,
  });

  String username;
  String email;
  String position;

  factory UserCreated.fromJson(Map<String, dynamic> json) => UserCreated(
        username: json["username"],
        email: json["email"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "position": position,
      };
}
