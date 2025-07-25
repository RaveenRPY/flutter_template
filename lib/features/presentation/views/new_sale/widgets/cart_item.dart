import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_spacing.dart';
import '../../../../../utils/app_stylings.dart';

class CartItem extends StatelessWidget {
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

  // Replace _isSquareScreen with _isCompactScreen
  bool _isCompactScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspect = size.width / size.height;
    // Check for 1:1 aspect ratio
    if (aspect > 0.95 && aspect < 1.05) return true;
    // Check for 1024x768 or 768x1024 (allow some tolerance for device pixel ratio)
    if ((size.width.round() == 1024 && size.height.round() == 768) ||
        (size.width.round() == 768 && size.height.round() == 1024)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompactScreen(context)) {
      return _buildCompactCartItem(context);
    } else {
      return _buildNormalCartItem(context);
    }
  }

  Widget _buildCompactCartItem(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primaryColor.withOpacity(0.1),
        highlightColor: AppColors.primaryColor.withOpacity(0.05),
        child: Container(
          margin: EdgeInsets.only(bottom: isLastItem ? 0 : 6),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.3) : AppColors.darkBlue.withOpacity(0.15),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection Checkbox and Image
              Column(
                children: [
                  if (isSelectionMode)
                    Container(
                      width: 18,
                      height: 18,
                      margin: EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.darkGrey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 14, color: AppColors.whiteColor)
                          : null,
                    ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: productImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              productImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            HugeIcons.strokeRoundedPackage,
                            size: 18,
                            color: AppColors.primaryColor.withOpacity(0.8),
                          ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              // Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      style: AppStyling.semi12Black.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    // Product Code and Unit Price
                    Row(
                      children: [
                        Container(
                          padding:  EdgeInsets.symmetric(
                            horizontal: 9.sp,
                            vertical: 5.sp,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            productCode,
                            style: AppStyling.regular10Grey.copyWith(
                                color: AppColors.whiteColor.withOpacity(1),
                                fontSize: 9.sp,
                                height: 1
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          NumberFormat.currency(locale: 'en_US', symbol: 'Rs. ', decimalDigits: 2).format(unitPrice),
                          style: AppStyling.regular10Grey.copyWith(fontSize: 10, color: AppColors.darkGrey.withOpacity(0.6)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    1.verticalSpace,
                    // Quantity Controls and Total Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Quantity Controls
                        if (!isSelectionMode)
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
                                    onTap: onDecrement,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    splashColor:
                                    AppColors.primaryColor.withOpacity(0.2),
                                    highlightColor:
                                    AppColors.primaryColor.withOpacity(0.1),
                                    child: Container(
                                      padding: EdgeInsets.all(6.sp),
                                      child: Icon(
                                        Icons.remove,
                                        size: 13,
                                        color: AppColors.darkBlue.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ),
                                // Quantity Display
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
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
                                    quantity.toString(),
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
                                    onTap: onIncrement,
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
                                        Icons.add,
                                        size: 13,
                                        color: AppColors.darkBlue.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Spacer(),
                        // Total Price
                        Text(
                          NumberFormat.currency(locale: 'en_US', symbol: 'Rs. ', decimalDigits: 2).format(totalPrice),
                          style: AppStyling.semi12Black.copyWith(fontSize: 12, color: AppColors.darkBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Remove Button (optional, can be an icon at the end)
              if (onRemove != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: AppColors.darkGrey.withOpacity(0.5)),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalCartItem(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLastItem ? 0 : 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.0)
                : AppColors.darkGrey.withOpacity(0.0),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.3)
              : AppColors.darkBlue.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          highlightColor: AppColors.primaryColor.withOpacity(0.05),
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
            child: Row(
              children: [
                // Selection Checkbox (only visible in selection mode)
                if (isSelectionMode) ...[
                  Container(
                    width: 13.sp,
                    height: 13.sp,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.darkGrey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 10.sp,
                            color: AppColors.whiteColor,
                          )
                        : null,
                  ),
                  0.8.horizontalSpace,
                ],

                // Product Image/Icon
                Container(
                  width: 18.sp,
                  height: 18.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            productImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          HugeIcons.strokeRoundedPackage,
                          size: 13.sp,
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
                        productName,
                        style: AppStyling.semi12Black.copyWith(
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      0.4.verticalSpace,
                      // Product Code and Unit Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding:  EdgeInsets.symmetric(
                              horizontal: 9.sp,
                              vertical: 5.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              productCode,
                              style: AppStyling.regular10Grey.copyWith(
                                color: AppColors.whiteColor.withOpacity(1),
                                fontSize: 9.sp,
                                height: 1
                              ),
                            ),
                          ),
                          0.5.horizontalSpace,
                          Text(
                            NumberFormat.currency(
                              locale: 'en_US',
                              symbol: 'Rs. ',
                              decimalDigits: 2,
                            ).format(unitPrice),
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
                      ).format(totalPrice),
                      style: AppStyling.semi12Black.copyWith(
                        color: AppColors.darkBlue,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),

                // Quantity Controls (disabled in selection mode)
                if (!isSelectionMode) ...[
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
                            onTap: onDecrement,
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
                            quantity.toString(),
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
                            onTap: onIncrement,
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
