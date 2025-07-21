import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_spacing.dart';
import '../../../../../utils/app_stylings.dart';

class CartItem extends StatefulWidget {
  final String productName;
  final String productCode;
  final double unitPrice;
  final double totalPrice;
  final int quantity;
  final String? productImage;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final bool isLastItem;
  final bool? isForEdit;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const CartItem({
    super.key,
    this.productName = "Abiman Takkali 125g",
    this.productCode = "AT125",
    this.unitPrice = 12000.00,
    this.totalPrice = 24000.00,
    this.quantity = 2,
    this.productImage,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.isLastItem = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.isForEdit = false,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: widget.isLastItem ? 0 : 8,
        left: 4,
        right: 4,
      ),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? AppColors.primaryColor.withOpacity(0.0)
                : AppColors.darkGrey.withOpacity(0.0),
            blurRadius: widget.isSelected ? 12 : 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primaryColor.withOpacity(0.3)
              : AppColors.darkBlue.withOpacity(0.2),
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          highlightColor: AppColors.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Selection Checkbox (only visible in selection mode)
                if (widget.isSelectionMode) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.primaryColor
                          : AppColors.transparent,
                      // borderRadius: BorderRadius.circular(4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.primaryColor
                            : AppColors.darkGrey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.whiteColor,
                          )
                        : null,
                  ),
                  0.8.horizontalSpace,
                ],

                // Product Image/Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: widget.productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.productImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          HugeIcons.strokeRoundedPackage,
                          size: 20,
                          color: AppColors.primaryColor.withOpacity(0.8),
                        ),
                ),
                1.horizontalSpace,

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.productName,
                        style: AppStyling.semi12Black.copyWith(
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      0.3.verticalSpace,
                      // Product Code and Unit Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.productCode,
                              style: AppStyling.regular10Grey.copyWith(
                                color: AppColors.darkGrey.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          0.5.horizontalSpace,
                          Text(
                            NumberFormat.currency(
                              locale: 'en_US',
                              symbol: 'Rs. ',
                              decimalDigits: 2,
                            ).format(widget.unitPrice),
                            style: AppStyling.regular12Grey.copyWith(
                              color: AppColors.darkGrey.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Total Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'en_US',
                        symbol: 'Rs. ',
                        decimalDigits: 2,
                      ).format(widget.totalPrice),
                      style: AppStyling.semi12Black.copyWith(
                        color: AppColors.darkBlue,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),

                // Quantity Controls (disabled in selection mode)
                if (!widget.isSelectionMode) ...[
                  1.horizontalSpace,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkGrey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease Button
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: widget.onDecrement,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            splashColor:
                                AppColors.primaryColor.withOpacity(0.2),
                            highlightColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                HugeIcons.strokeRoundedRemove01,
                                size: 14,
                                color: AppColors.darkBlue.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        // Quantity Display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: AppColors.darkGrey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.quantity.toString(),
                            style: AppStyling.semi12Black.copyWith(
                              color: AppColors.darkBlue,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        // Increase Button
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: widget.onIncrement,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            splashColor:
                                AppColors.primaryColor.withOpacity(0.2),
                            highlightColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                HugeIcons.strokeRoundedAdd01,
                                size: 14,
                                color: AppColors.darkBlue.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
