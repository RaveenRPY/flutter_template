import 'dart:convert';

BaseRequest baseRequestFromJson(String str) =>
    BaseRequest.fromJson(json.decode(str));

String baseRequestToJson(BaseRequest data) => json.encode(data.toJson());

class BaseRequest {
  String? channel;
  String? username;
  String? ip;
  String? userAgent;

  BaseRequest({
    this.channel,
    this.username,
    this.ip,
    this.userAgent,
  });

  factory BaseRequest.fromJson(Map<String, dynamic> json) => BaseRequest(
        channel: json["channel"],
        username: json["username"],
        ip: json["ip"],
        userAgent: json["userAgent"],
      );

  Map<String, dynamic> toJson() => {
        "channel": channel,
        "username": username,
        "ip": ip,
        "userAgent": userAgent,
      };
}
