import 'dart:convert';

CashInOutRequest cashInOutRequestFromJson(String str) => CashInOutRequest.fromJson(json.decode(str));

String cashInOutRequestToJson(CashInOutRequest data) => json.encode(data.toJson());

class CashInOutRequest {
  final String? message;
  final String? cashInOut;
  final double? amount;
  final String? remark;

  CashInOutRequest({
    this.message,
    this.cashInOut,
    this.amount,
    this.remark,
  });

  factory CashInOutRequest.fromJson(Map<String, dynamic> json) => CashInOutRequest(
    message: json["message"],
    cashInOut: json["cashInOut"],
    amount: json["amount"],
    remark: json["remark"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "cashInOut": cashInOut,
    "amount": amount,
    "remark": remark,
  };
}
