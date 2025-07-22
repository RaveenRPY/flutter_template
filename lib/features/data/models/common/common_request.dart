import 'dart:convert';

CommonRequest commonRequestFromJson(String str) => CommonRequest.fromJson(json.decode(str));

String commonRequestToJson(CommonRequest data) => json.encode(data.toJson());

class CommonRequest {
  final String? message;

  CommonRequest({
    this.message,
  });

  factory CommonRequest.fromJson(Map<String, dynamic> json) => CommonRequest(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
