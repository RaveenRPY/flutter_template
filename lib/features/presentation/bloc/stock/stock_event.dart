import 'package:AventaPOS/features/data/models/requests/checkout.dart';

import '../base_bloc.dart';

abstract class StockEvent extends BaseEvent {}

class GetStockEvent extends StockEvent {}

class ViewTodayCashInOutEvent extends StockEvent {}

class CashInOutEvent extends StockEvent {
  final String? cashInOut;
  final double? amount;
  final String? remark;

  CashInOutEvent({this.cashInOut, this.amount, this.remark});
}

class CheckOutEvent extends StockEvent {
  final String? paymentType;
  final int? customer;
  final String? salesType;
  final double? totalAmount;
  final double? payAmount;
  final String? remark;
  final List<BillingItem>? billingItem;

  CheckOutEvent({
    this.paymentType,
    this.customer,
    this.salesType,
    this.totalAmount,
    this.payAmount,
    this.remark,
    this.billingItem,
  });
}
