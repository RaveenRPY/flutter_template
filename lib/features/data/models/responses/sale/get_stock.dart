import 'dart:convert';

import 'package:AventaPOS/features/data/models/common/base_response.dart';
import 'package:AventaPOS/features/domain/entities/data.dart';

GetStockResponse getStockResponseFromJson(String str) =>
    GetStockResponse.fromJson(json.decode(str));

String getStockResponseToJson(GetStockResponse data) =>
    json.encode(data.toJson());

class GetStockResponse extends Serializable {
  final List<Stock>? stock;

  GetStockResponse({
    this.stock,
  });

  factory GetStockResponse.fromJson(Map<String, dynamic> json) =>
      GetStockResponse(
        stock: json["stock"] == null
            ? []
            : List<Stock>.from(json["stock"]!.map((x) => Stock.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "stock": stock == null
            ? []
            : List<dynamic>.from(stock!.map((x) => x.toJson())),
      };
}

class Stock {
  final int? id;
  final Item? item;
  final double? labelPrice;
  final double? itemCost;
  final double? retailPrice;
  final double? wholesalePrice;
  final int? retailDiscount;
  final int? wholesaleDiscount;
  final int? qty;
  final String? status;
  final String? statusDescription;
  int? cartQty;

  Stock({
    this.id,
    this.item,
    this.labelPrice,
    this.itemCost,
    this.retailPrice,
    this.wholesalePrice,
    this.retailDiscount,
    this.wholesaleDiscount,
    this.qty,
    this.status,
    this.statusDescription,
    this.cartQty,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        id: json["id"],
        item: json["item"] == null ? null : Item.fromJson(json["item"]),
        labelPrice: json["lablePrice"],
        itemCost: json["itemCost"],
        retailPrice: json["retailPrice"],
        wholesalePrice: json["wholesalePrice"],
        retailDiscount: json["retailDiscount"],
        wholesaleDiscount: json["wholesaleDiscount"],
        qty: json["qty"],
        status: json["status"],
        statusDescription: json["statusDescription"],
        cartQty: null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item": item?.toJson(),
        "lablePrice": labelPrice,
        "itemCost": itemCost,
        "retailPrice": retailPrice,
        "wholesalePrice": wholesalePrice,
        "retailDiscount": retailDiscount,
        "wholesaleDiscount": wholesaleDiscount,
        "qty": qty,
        "status": status,
        "statusDescription": statusDescription,
        // cartQty is intentionally not serialized
      };
}

class Item {
  final int? id;
  final String? code;
  final String? description;
  final String? status;
  final String? statusDescription;
  final Data? category;
  final Data? brand;
  final String? unit;
  final String? unitDescription;

  Item({
    this.id,
    this.code,
    this.description,
    this.status,
    this.statusDescription,
    this.category,
    this.brand,
    this.unit,
    this.unitDescription,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        code: json["code"],
        description: json["description"],
        status: json["status"],
        statusDescription: json["statusDescription"],
        category:
            json["category"] == null ? null : Data.fromJson(json["category"]),
        brand: json["brand"] == null ? null : Data.fromJson(json["brand"]),
        unit: json["unit"],
        unitDescription: json["unitDescription"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "description": description,
        "status": status,
        "statusDescription": statusDescription,
        "category": category?.toJson(),
        "brand": brand?.toJson(),
        "unit": unit,
        "unitDescription": unitDescription,
      };
}
