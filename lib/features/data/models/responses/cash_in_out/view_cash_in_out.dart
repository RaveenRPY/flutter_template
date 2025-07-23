import 'dart:convert';

import 'package:AventaPOS/features/data/models/common/base_response.dart';

ViewCashInOutResponse viewCashInOutResponseFromJson(String str) =>
    ViewCashInOutResponse.fromJson(json.decode(str));

String viewCashInOutResponseToJson(ViewCashInOutResponse data) =>
    json.encode(data.toJson());

class ViewCashInOutResponse extends Serializable {
  final List<Cash>? cash;

  ViewCashInOutResponse({
    this.cash,
  });

  factory ViewCashInOutResponse.fromJson(Map<String, dynamic> json) =>
      ViewCashInOutResponse(
        cash: json["cash"] == null
            ? []
            : List<Cash>.from(json["cash"]!.map((x) => Cash.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cash": cash == null
            ? []
            : List<dynamic>.from(cash!.map((x) => x.toJson())),
      };
}

class Cash {
  final int? id;
  final DateTime? date;
  final String? cashInOut;
  final String? cashInOutDescription;
  final String? remark;
  final double? amount;

  Cash({
    this.id,
    this.date,
    this.cashInOut,
    this.cashInOutDescription,
    this.remark,
    this.amount,
  });

  factory Cash.fromJson(Map<String, dynamic> json) => Cash(
        id: json["id"],
        date: json["date"],
        cashInOut: json["cashInOut"],
        cashInOutDescription: json["cashInOutDescription"],
        remark: json["remark"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "cashInOut": cashInOut,
        "cashInOutDescription": cashInOutDescription,
        "remark": remark,
        "amount": amount,
      };
}
