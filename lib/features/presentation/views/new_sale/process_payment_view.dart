import 'package:flutter/material.dart';

import '../../../data/models/responses/sale/get_stock.dart';

class ProcessPaymentView extends StatefulWidget {
  final PaymentParams params;
  const ProcessPaymentView(
      {super.key, required this.params});

  @override
  State<ProcessPaymentView> createState() => _ProcessPaymentViewState();
}

class _ProcessPaymentViewState extends State<ProcessPaymentView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PaymentParams {
  final List<Stock> cartItemList;
  final double total;

  PaymentParams({required this.cartItemList, required this.total});
}
