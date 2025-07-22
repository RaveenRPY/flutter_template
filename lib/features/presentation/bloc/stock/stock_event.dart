import '../base_bloc.dart';

abstract class StockEvent extends BaseEvent {}

class GetStockEvent extends StockEvent {}
