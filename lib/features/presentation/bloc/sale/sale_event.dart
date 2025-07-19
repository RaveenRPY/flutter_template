import '../base_bloc.dart';

abstract class SaleEvent extends BaseEvent {}

class SaleTabChangedEvent extends SaleEvent {
  final int selectedTabIndex;
  
  SaleTabChangedEvent(this.selectedTabIndex);
}

class SaleInitializedEvent extends SaleEvent {}

class SaleItemAddedEvent extends SaleEvent {
  final String itemId;
  final int quantity;
  
  SaleItemAddedEvent(this.itemId, this.quantity);
}

class SaleItemRemovedEvent extends SaleEvent {
  final String itemId;
  
  SaleItemRemovedEvent(this.itemId);
}

class SaleCompletedEvent extends SaleEvent {
  final double totalAmount;
  final String paymentMethod;
  
  SaleCompletedEvent(this.totalAmount, this.paymentMethod);
} 