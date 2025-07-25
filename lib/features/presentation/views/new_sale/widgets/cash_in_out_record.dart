import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_stylings.dart';

class CashInOutRecord extends StatelessWidget {
  final DateTime date;
  final String remark;
  final double amount;
  final bool isLast;

  const CashInOutRecord(
      {super.key,
      required this.date,
      required this.remark,
      required this.amount,
      required this.isLast});

  @override
  Widget build(BuildContext context) {
    String formatedAmount = NumberFormat.currency(symbol: '').format(amount);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey.withOpacity(0.0),
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? AppColors.transparent
                : AppColors.primaryColor.withOpacity(0.4),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
                child: Text(
              DateFormat("yyyy-MM-dd").format(date),
              textAlign: TextAlign.center,
              style: AppStyling.regular12Black,
            )),
            Expanded(
                child: Text(
              DateFormat("hh:mm:ss a").format(date),
              textAlign: TextAlign.center,
              style: AppStyling.regular12Black,
            )),
            Expanded(
                child: Text(
              remark,
              textAlign: TextAlign.center,
              style: AppStyling.regular12Black,
            )),
            Expanded(
                child: Text(
              formatedAmount,
              textAlign: TextAlign.center,
              style: AppStyling.regular12Black,
            )),
          ],
        ),
      ),
    );
  }
}
