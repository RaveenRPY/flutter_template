import 'package:AventaPOS/features/data/models/responses/cash_in_out/view_cash_in_out.dart';
import 'package:AventaPOS/features/data/models/responses/checkout/checkout.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

import '../base_bloc.dart';

abstract class StockState extends BaseState<StockState> {}

class StockInitial extends StockState {}

class GetStockSuccessState extends StockState {
  final String? message;
  final List<Stock>? stockList;

  GetStockSuccessState({this.message, this.stockList});
}

class GetStockFailedState extends StockState {
  final int? errorCode;
  final String? errorMsg;

  GetStockFailedState({this.errorCode, this.errorMsg});
}

class CheckoutSuccessState extends StockState {
  final String? msg;
  final CheckOutResponse? response;

  CheckoutSuccessState({this.msg, this.response});
}

class CheckoutFailedState extends StockState {
  final int? errorCode;
  final String? errorMsg;

  CheckoutFailedState({this.errorCode, this.errorMsg});
}

class ViewTodayCashInOutLoadingState extends StockState {}

class ViewTodayCashInOutSuccessState extends StockState {
  final String? msg;
  final List<Cash>? dataList;

  ViewTodayCashInOutSuccessState({this.msg, this.dataList});
}

class ViewTodayCashInOutFailedState extends StockState {
  final int? errorCode;
  final String? errorMsg;

  ViewTodayCashInOutFailedState({this.errorCode, this.errorMsg});
}

class CashInOutLoadingState extends StockState {}

class CashInOutSuccessState extends StockState {
  final String? msg;

  CashInOutSuccessState({this.msg});
}

class CashInOutFailedState extends StockState {
  final int? errorCode;
  final String? errorMsg;

  CashInOutFailedState({this.errorCode, this.errorMsg});
}
