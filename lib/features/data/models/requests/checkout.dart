import 'dart:convert';

CheckOutRequest checkOutRequestFromJson(String str) => CheckOutRequest.fromJson(json.decode(str));

String checkOutRequestToJson(CheckOutRequest data) => json.encode(data.toJson());

class CheckOutRequest {
  final String? message;
  final String? cashierUser;
  final String? paymentType;
  final int? customer;
  final String? salesType;
  final double? totalAmount;
  final double? payAmount;
  final String? remark;
  final List<BillingItem>? billingItem;

  CheckOutRequest({
    this.message,
    this.cashierUser,
    this.paymentType,
    this.customer,
    this.salesType,
    this.totalAmount,
    this.payAmount,
    this.remark,
    this.billingItem,
  });

  factory CheckOutRequest.fromJson(Map<String, dynamic> json) => CheckOutRequest(
    message: json["message"],
    cashierUser: json["cashierUser"],
    paymentType: json["paymentType"],
    customer: json["customer"],
    salesType: json["salesType"],
    totalAmount: json["totalAmount"],
    payAmount: json["payAmount"],
    remark: json["remark"],
    billingItem: json["billingItem"] == null ? [] : List<BillingItem>.from(json["billingItem"]!.map((x) => BillingItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "cashierUser": cashierUser,
    "paymentType": paymentType,
    "customer": customer,
    "salesType": salesType,
    "totalAmount": totalAmount,
    "payAmount": payAmount,
    "remark": remark,
    "billingItem": billingItem == null ? [] : List<dynamic>.from(billingItem!.map((x) => x.toJson())),
  };
}

class BillingItem {
  final int? qty;
  final double? salesPrice;
  final int? salesDiscount;
  final int? stock;

  BillingItem({
    this.qty,
    this.salesPrice,
    this.salesDiscount,
    this.stock,
  });

  factory BillingItem.fromJson(Map<String, dynamic> json) => BillingItem(
    qty: json["qty"],
    salesPrice: json["salesPrice"],
    salesDiscount: json["salesDiscount"],
    stock: json["stock"],
  );

  Map<String, dynamic> toJson() => {
    "qty": qty,
    "salesPrice": salesPrice,
    "salesDiscount": salesDiscount,
    "stock": stock,
  };
}
