import 'dart:convert';

NegativeResponse negativeResponseFromJson(String str) =>
    NegativeResponse.fromJson(json.decode(str));

String negativeResponseToJson(NegativeResponse data) =>
    json.encode(data.toJson());

class NegativeResponse {
  NegativeResponse({
    this.message,
  });

  String message;

  factory NegativeResponse.fromJson(Map<String, dynamic> json) =>
      NegativeResponse(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
