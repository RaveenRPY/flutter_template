import '../base_bloc.dart';
import '../../models/navigation_item.dart';

abstract class SaleState extends BaseState {}

class SaleInitialState extends SaleState {}

class SaleLoadingState extends SaleState {}

class SaleLoadedState extends SaleState {
   int selectedTabIndex;
   List<SaleItem> cartItems;
   double totalAmount;
   List<NavigationItem> navigationItems;
  
  SaleLoadedState({
    required this.selectedTabIndex,
    required this.cartItems,
    required this.totalAmount,
    required this.navigationItems,
  });
}

class SaleErrorState extends SaleState {
  final String error;
  
  SaleErrorState(this.error);
}

class SaleCompletedState extends SaleState {
  final String transactionId;
  final double amount;
  
  SaleCompletedState(this.transactionId, this.amount);
}

class SaleItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  
  SaleItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
  
  double get totalPrice => price * quantity;
} 