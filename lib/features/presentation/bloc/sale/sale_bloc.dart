import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../utils/app_images.dart';
import '../base_bloc.dart';
import 'sale_event.dart';
import 'sale_state.dart';
import '../../models/navigation_item.dart';

class SaleBloc extends BaseBloc<SaleEvent, SaleState> {
  int _selectedTabIndex = 0;
  final List<SaleItem> _cartItems = [];
  double _totalAmount = 0.0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(icon: HugeIcons.strokeRoundedShoppingCartCheckIn02,),
    NavigationItem(icon: HugeIcons.strokeRoundedReturnRequest,),
    NavigationItem(icon: HugeIcons.strokeRoundedReturnRequest,),
    NavigationItem(icon: HugeIcons.strokeRoundedReturnRequest,),
    NavigationItem(icon: HugeIcons.strokeRoundedReturnRequest,),
  ];

  SaleBloc() : super(SaleInitialState()) {
    on<SaleInitializedEvent>(_onSaleInitialized);
    on<SaleTabChangedEvent>(_onSaleTabChanged);
    on<SaleItemAddedEvent>(_onSaleItemAdded);
    on<SaleItemRemovedEvent>(_onSaleItemRemoved);
    on<SaleCompletedEvent>(_onSaleCompleted);
  }

  void _onSaleInitialized(SaleInitializedEvent event, Emitter<SaleState> emit) async {
    emit(SaleLoadingState());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(SaleLoadedState(
      selectedTabIndex: _selectedTabIndex,
      cartItems: _cartItems,
      totalAmount: _totalAmount,
      navigationItems: _navigationItems,
    ));
  }

  void _onSaleTabChanged(SaleTabChangedEvent event, Emitter<SaleState> emit) {
    _selectedTabIndex = event.selectedTabIndex;
    emit(SaleLoadedState(
      selectedTabIndex: _selectedTabIndex,
      cartItems: _cartItems,
      totalAmount: _totalAmount,
      navigationItems: _navigationItems,
    ));
  }

  void _onSaleItemAdded(SaleItemAddedEvent event, Emitter<SaleState> emit) {
    _addItemToCart(event.itemId, event.quantity);
    emit(SaleLoadedState(
      selectedTabIndex: _selectedTabIndex,
      cartItems: _cartItems,
      totalAmount: _totalAmount,
      navigationItems: _navigationItems,
    ));
  }

  void _onSaleItemRemoved(SaleItemRemovedEvent event, Emitter<SaleState> emit) {
    _removeItemFromCart(event.itemId);
    emit(SaleLoadedState(
      selectedTabIndex: _selectedTabIndex,
      cartItems: _cartItems,
      totalAmount: _totalAmount,
      navigationItems: _navigationItems,
    ));
  }

  void _onSaleCompleted(SaleCompletedEvent event, Emitter<SaleState> emit) async {
    emit(SaleLoadingState());
    await Future.delayed(const Duration(seconds: 1));
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    emit(SaleCompletedState(transactionId, event.totalAmount));
  }

  void _addItemToCart(String itemId, int quantity) {
    // Mock data - in real app, this would come from a repository
    final mockItems = {
      'item1': SaleItem(
        id: 'item1',
        name: 'Product 1',
        price: 10.99,
        quantity: 1,
      ),
      'item2': SaleItem(
        id: 'item2',
        name: 'Product 2',
        price: 15.50,
        quantity: 1,
      ),
      'item3': SaleItem(
        id: 'item3',
        name: 'Product 3',
        price: 8.75,
        quantity: 1,
      ),
    };

    final item = mockItems[itemId];
    if (item != null) {
      final existingItemIndex = _cartItems.indexWhere((cartItem) => cartItem.id == itemId);
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex] = SaleItem(
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: _cartItems[existingItemIndex].quantity + quantity,
          imageUrl: item.imageUrl,
        );
      } else {
        _cartItems.add(SaleItem(
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: quantity,
          imageUrl: item.imageUrl,
        ));
      }
      _calculateTotal();
    }
  }

  void _removeItemFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
} 