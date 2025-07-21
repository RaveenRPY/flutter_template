import 'dart:convert';

import 'package:AventaPOS/features/data/models/common/base_response.dart';
import 'package:AventaPOS/features/domain/entities/data.dart';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse extends Serializable {
  final String? accessToken;
  final String? username;
  final String? email;
  final String? mobile;
  final bool? reset;
  final String? status;
  final String? statusDescription;
  final String? lastLoggedChannel;
  final String? lastLoggedChannelDescription;
  final String? lastPasswordChangeDate;
  final String? lastLoggedDate;
  final String? mbLastLoggedDate;
  final String? opLastLoggedDate;
  final bool? expectingFirstTimeLogging;
  final String? passwordExpiredDate;
  final Data? location;
  final bool? opening;

  LoginResponse({
    this.accessToken,
    this.username,
    this.email,
    this.mobile,
    this.reset,
    this.status,
    this.statusDescription,
    this.lastLoggedChannel,
    this.lastLoggedChannelDescription,
    this.lastPasswordChangeDate,
    this.lastLoggedDate,
    this.mbLastLoggedDate,
    this.opLastLoggedDate,
    this.expectingFirstTimeLogging,
    this.passwordExpiredDate,
    this.location,
    this.opening,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json["accessToken"],
    username: json["username"],
    email: json["email"],
    mobile: json["mobile"],
    reset: json["reset"],
    status: json["status"],
    statusDescription: json["statusDescription"],
    lastLoggedChannel: json["lastLoggedChannel"],
    lastLoggedChannelDescription: json["lastLoggedChannelDescription"],
    lastPasswordChangeDate: json["lastPasswordChangeDate"],
    lastLoggedDate: json["lastLoggedDate"],
    mbLastLoggedDate: json["mbLastLoggedDate"],
    opLastLoggedDate: json["opLastLoggedDate"],
    expectingFirstTimeLogging: json["expectingFirstTimeLogging"],
    passwordExpiredDate: json["passwordExpiredDate"],
    location: json["location"] == null ? null : Data.fromJson(json["location"]),
    opening: json["opening"],
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "username": username,
    "email": email,
    "mobile": mobile,
    "reset": reset,
    "status": status,
    "statusDescription": statusDescription,
    "lastLoggedChannel": lastLoggedChannel,
    "lastLoggedChannelDescription": lastLoggedChannelDescription,
    "lastPasswordChangeDate": lastPasswordChangeDate,
    "lastLoggedDate": lastLoggedDate,
    "mbLastLoggedDate": mbLastLoggedDate,
    "opLastLoggedDate": opLastLoggedDate,
    "expectingFirstTimeLogging": expectingFirstTimeLogging,
    "passwordExpiredDate": passwordExpiredDate,
    "location": location?.toJson(),
    "opening": opening,
  };
}