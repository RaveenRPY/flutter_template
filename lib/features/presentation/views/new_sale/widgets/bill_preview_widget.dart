import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_stylings.dart';
import '../../../../data/models/responses/sale/get_stock.dart';

class ReceiptPreview extends StatelessWidget {
  final List<Stock> itemList;
  final String invoiceNo;
  final DateTime invoiceDate;
  final String cashier;
  final String paymentType;
  final String outlet;
  final String total;
  final String cash;
  final String changes;
  final bool isRetail;

  const ReceiptPreview({
    super.key,
    required this.itemList,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.cashier,
    required this.paymentType,
    required this.outlet,
    required this.total,
    required this.cash,
    required this.changes,
    required this.isRetail,
  });

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: AppStyling.regular12Black.copyWith(color: AppColors.blackColor),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            border: Border.all(color: AppColors.blackColor, width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text('DPD Chemical', style: AppStyling.bold18Black.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(outlet, style: AppStyling.semi14Black),
              ),
              Center(
                child: Text('076 891 85 70 / 078 60 65 410', style: AppStyling.semi12Black),
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: AppColors.blackColor),
              Center(
                child: Text( isRetail ?'SALES INVOICE' : 'WHOLESALE INVOICE', style: AppStyling.semi14Black.copyWith(fontWeight: FontWeight.bold)),
              ),
              Divider(thickness: 1, color: AppColors.blackColor),
              Text('Date       : ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(invoiceDate)}'),
              Text('Invoice No : $invoiceNo'),
              // Text('Cashier    : $cashier'),
              Text('Outlet     : $outlet'),
              Text('Payment    : $paymentType'),
              Divider(thickness: 1, color: AppColors.blackColor),
              Row(
                children: [
                  SizedBox(width: 32, child: Text('No', style: AppStyling.semi12Black)),
                  SizedBox(width: 110, child: Text('Item Name', style: AppStyling.semi12Black)),
                  SizedBox(width: 60, child: Text('Price', style: AppStyling.semi12Black)),
                  SizedBox(width: 40, child: Text('Qty', style: AppStyling.semi12Black)),
                  Expanded(child: Text('Total', style: AppStyling.semi12Black)),
                ],
              ),
              Divider(thickness: 1, color: AppColors.blackColor),
              ...itemList.asMap().entries.expand((entry) {
                final i = entry.key;
                final item = entry.value;
                totalItems += item.cartQty as int;
                final name = item.item?.description ?? '';
                final priceStr = _formatCurrency(item.retailPrice ?? 0);
                final qtyStr = (item.cartQty ?? 0).toString();
                final totalStr = _formatCurrency((item.cartQty ?? 0) * (item.retailPrice ?? 0));
                List<Widget> lines = [];
                if (name.length > 18) {
                  lines.add(Row(
                    children: [
                      SizedBox(width: 32, child: Text('${i + 1}')),
                      SizedBox(width: 110, child: Text(name.substring(0, 18))),
                      SizedBox(width: 60, child: Text(priceStr)),
                      SizedBox(width: 40, child: Text(qtyStr)),
                      Expanded(child: Text(totalStr)),
                    ],
                  ));
                  lines.add(Row(
                    children: [
                      SizedBox(width: 32),
                      SizedBox(width: 110, child: Text(name.substring(18))),
                    ],
                  ));
                } else {
                  lines.add(Row(
                    children: [
                      SizedBox(width: 32, child: Text('${i + 1}')),
                      SizedBox(width: 110, child: Text(name)),
                      SizedBox(width: 60, child: Text(priceStr)),
                      SizedBox(width: 40, child: Text(qtyStr)),
                      Expanded(child: Text(totalStr)),
                    ],
                  ));
                }
                return lines;
              }),
              Divider(thickness: 1, color: AppColors.blackColor),
              Text('TOTAL ITEMS    :   $totalItems', style: AppStyling.semi14Black),
              Divider(thickness: 1, color: AppColors.blackColor),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Divider(thickness: 1, color: AppColors.blackColor),
                    Text('Total Amount : $total', style: AppStyling.semi14Black),
                    Text('Cash : $cash', style: AppStyling.semi14Black),
                    Text('Changes : $changes', style: AppStyling.semi14Black),
                  ],
                ),
              ),
              Divider(thickness: 1, color: AppColors.blackColor),
              const SizedBox(height: 8),
              Text('NOTES:', style: AppStyling.semi12Black),
              Text('Please verify items upon receipt.'),
              Text('Report any missing/damaged items within 24hrs.'),
              Divider(thickness: 1, color: AppColors.blackColor),
              const SizedBox(height: 8),
              Center(
                child: Text('Thank You!', style: AppStyling.semi14Black),
              ),
              Divider(thickness: 1, color: AppColors.blackColor),
              const SizedBox(height: 8),
              Center(
                child: Text('Powered By AventaPOS', style: AppStyling.medium12Black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
