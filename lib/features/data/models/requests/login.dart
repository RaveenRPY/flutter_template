// To parse this JSON data, do
//
//     final loginRequest = loginRequestFromJson(jsonString);

import 'dart:convert';

LoginRequest loginRequestFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  final String? message;
  final String? password;

  LoginRequest({
    this.message,
    this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        message: json["message"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "password": password,
      };
}
