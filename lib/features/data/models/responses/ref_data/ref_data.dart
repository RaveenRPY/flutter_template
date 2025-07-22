import 'dart:convert';

import 'package:AventaPOS/features/domain/entities/data.dart';

RefDataResponse refDataResponseFromJson(String str) =>
    RefDataResponse.fromJson(json.decode(str));

String refDataResponseToJson(RefDataResponse data) =>
    json.encode(data.toJson());

class RefDataResponse {
  final List<Data>? salesType;
  final List<Data>? cashInOut;
  final List<Customer>? customer;

  RefDataResponse({
    this.salesType,
    this.cashInOut,
    this.customer,
  });

  factory RefDataResponse.fromJson(Map<String, dynamic> json) =>
      RefDataResponse(
        salesType: json["salesType"] == null
            ? []
            : List<Data>.from(json["salesType"]!.map((x) => Data.fromJson(x))),
        cashInOut: json["cashInOut"] == null
            ? []
            : List<Data>.from(json["cashInOut"]!.map((x) => Data.fromJson(x))),
        customer: json["customer"] == null
            ? []
            : List<Customer>.from(
                json["customer"]!.map((x) => Customer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "salesType": salesType == null
            ? []
            : List<dynamic>.from(salesType!.map((x) => x.toJson())),
        "cashInOut": cashInOut == null
            ? []
            : List<dynamic>.from(cashInOut!.map((x) => x.toJson())),
        "customer": customer == null
            ? []
            : List<dynamic>.from(customer!.map((x) => x.toJson())),
      };
}

class Customer {
  final int? id;
  final String? name;
  final String? status;
  final String? statusDescription;

  Customer({
    this.id,
    this.name,
    this.status,
    this.statusDescription,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        statusDescription: json["statusDescription"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "statusDescription": statusDescription,
      };
}
