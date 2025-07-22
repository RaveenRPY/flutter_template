import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

import '../base_bloc.dart';

abstract class StockState extends BaseState<StockState> {}

class StockInitial extends StockState {}

class GetStockSuccessState extends StockState {
  final String? message;
  final List<Stock>? stockList;

  GetStockSuccessState({this.message,this.stockList});
}

class GetStockFailedState extends StockState {
  final int? errorCode;
  final String? errorMsg;

  GetStockFailedState({this.errorCode,this.errorMsg});
}
