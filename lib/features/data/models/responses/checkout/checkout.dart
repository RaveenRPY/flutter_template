import 'dart:convert';

import 'package:AventaPOS/features/data/models/common/base_response.dart';

CheckOutResponse checkOutResponseFromJson(String str) => CheckOutResponse.fromJson(json.decode(str));

String checkOutResponseToJson(CheckOutResponse data) => json.encode(data.toJson());

class CheckOutResponse extends Serializable{
  final String? invoiceNumber;
  final String? counter;
  final String? paymentType;
  final String? paymentTypeDescription;
  final String? customerName;
  final String? outletName;
  final String? salesType;
  final String? salesTypeDescription;
  final DateTime? invoiceDate;

  CheckOutResponse({
    this.invoiceNumber,
    this.counter,
    this.paymentType,
    this.paymentTypeDescription,
    this.customerName,
    this.outletName,
    this.salesType,
    this.salesTypeDescription,
    this.invoiceDate,
  });

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) => CheckOutResponse(
    invoiceNumber: json["invoiceNumber"],
    counter: json["counter"],
    paymentType: json["paymentType"],
    paymentTypeDescription: json["paymentTypeDescription"],
    customerName: json["customerName"],
    outletName: json["outletName"],
    salesType: json["salesType"],
    salesTypeDescription: json["salesTypeDescription"],
    invoiceDate: json["invoiceDate"] == null ? null : DateTime.parse(json["invoiceDate"]),
  );

  Map<String, dynamic> toJson() => {
    "invoiceNumber": invoiceNumber,
    "counter": counter,
    "paymentType": paymentType,
    "paymentTypeDescription": paymentTypeDescription,
    "customerName": customerName,
    "outletName": outletName,
    "salesType": salesType,
    "salesTypeDescription": salesTypeDescription,
    "invoiceDate": invoiceDate?.toIso8601String(),
  };
}
