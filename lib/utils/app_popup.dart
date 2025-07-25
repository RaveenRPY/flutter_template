import 'dart:ui';

import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_form_field.dart';
import 'package:AventaPOS/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';
import 'app_stylings.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

class PopupWindow extends StatefulWidget {
  String? itemName;
  String? itemCode;
  double? labelPrice;
  double? cost;
  int? qty;
  int? stockQty;
  double? salePrice;
  bool? isForEdit;
  final void Function(Stock, int, double)? onAddToCart;
  Stock? stock;

  PopupWindow(
      {super.key,
      this.itemName,
      this.itemCode,
      this.labelPrice,
      this.salePrice,
      this.cost,
      this.qty,
      this.stockQty,
      this.isForEdit,
      this.onAddToCart,
      this.stock});

  @override
  State<PopupWindow> createState() => _PopupWindowState();

  static void show(
    BuildContext context, {
    String? itemName,
    String? itemCode,
    double? labelPrice,
    double? cost,
    int? qty,
    int? stockQty,
    double? salePrice,
    bool? isForEdit,
    Stock? stock,
    void Function(Stock, int, double)? onAddToCart,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: true,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: PopupWindow(
              itemCode: itemCode,
              itemName: itemName,
              labelPrice: labelPrice,
              salePrice: salePrice,
              qty: qty,
              stockQty: stockQty,
              onAddToCart: onAddToCart,
              isForEdit: isForEdit ?? false,
              stock: stock,
              cost: cost,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
    );
  }
}

class _PopupWindowState extends State<PopupWindow> {
  final TextEditingController _labelPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _newSalePriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  final FocusNode _qtyFocusNode = FocusNode();
  final _qtyFormKey = GlobalKey<FormState>();
  final _newSalePriceFormKey = GlobalKey<FormState>();

  late double _salePrice;
  late int _qty;

  bool isCustomSalePriceValidated = true;
  bool isQtyValidated = true;

  @override
  void initState() {
    super.initState();
    _labelPriceController.text = widget.labelPrice.toString();
    _salePriceController.text = widget.salePrice.toString();
    _newSalePriceController.text = widget.salePrice.toString();
    _stockController.text = widget.stockQty.toString();

    _qtyFocusNode.requestFocus();
    _qtyController.text =
        (widget.qty ?? (widget.stockQty == 0 ? 0 : 1)).toString();

    _salePrice = widget.salePrice ?? 0;
    _qty = int.parse(_qtyController.text);

    // Initial validation for qty and custom sale price
    isQtyValidated = _qty > 0;
    isCustomSalePriceValidated = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _newSalePriceFormKey.currentState?.validate();
      _qtyFormKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            width: 60.h,
            height: 82.h,
            constraints: BoxConstraints(maxWidth: 85.w, maxHeight: 99.h),
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGrey.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
                border: Border(
                    top: BorderSide(color: AppColors.primaryColor, width: 10))),
            child: Column(
              children: [
                // Header (not scrollable)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.sp, 15.sp, 20.sp, 5.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.sp, left: 4.sp, right: 4.sp),
                        child: Text(
                          widget.itemName ?? "",
                          maxLines: 2,
                          style:
                              AppStyling.medium25Black.copyWith(fontSize: 30),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.sp, bottom: 20.sp),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.itemCode ?? "",
                          style: AppStyling.medium12Black.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Middle: Scrollable text fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: Column(
                      children: [
                        1.verticalSpace,
                        AventaFormField(
                          controller: _labelPriceController,
                          label: "Label Price",
                          isCurrency: true,
                          isReadOnly: true,
                        ),
                        SizedBox(height: 13.sp),
                        AventaFormField(
                          controller: _salePriceController,
                          label: "Sale Price",
                          isCurrency: true,
                          isReadOnly: true,
                        ),
                        SizedBox(height: 13.sp),
                        AventaFormField(
                          controller: _stockController,
                          label: "Available Qty",
                          isReadOnly: true,
                        ),
                        SizedBox(height: 13.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Form(
                                key: _newSalePriceFormKey,
                                child: AventaFormField(
                                  controller: _newSalePriceController,
                                  label: "Custom Sale Price",
                                  isCurrency: true,
                                  showCurrencySymbol: true,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        String cleanValue =
                                            value.replaceAll(',', '');
                                        if (cleanValue.isNotEmpty) {
                                          _salePrice =
                                              double.tryParse(cleanValue) ??
                                                  0.0;
                                        }
                                      }
                                    });
                                  },
                                  onCompleted: (){
                                    setState(() {
                                      _qtyFormKey.currentState?.validate();
                                      _newSalePriceFormKey.currentState?.validate();

                                      if((isQtyValidated &&
                                          isCustomSalePriceValidated &&
                                          _qty > 0)){
                                        if (widget.onAddToCart != null) {
                                          widget.onAddToCart!(
                                              widget.stock!, _qty, _salePrice);
                                        }
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  validator: (price) {
                                    if (price != null) {
                                      if (double.parse(
                                              price.replaceAll(',', '')) >
                                          widget.labelPrice!) {
                                        setState(() {
                                          isCustomSalePriceValidated = false;
                                        });
                                        return 'Sale price can\'t exceed the MRP';
                                      } else if (double.parse(
                                              price.replaceAll(',', '')) <
                                          (widget.cost ?? 1000)) {
                                        setState(() {
                                          isCustomSalePriceValidated = false;
                                        });
                                        return 'Please enter a higher price';
                                      }
                                    } else {
                                      setState(() {
                                        isCustomSalePriceValidated = false;
                                      });
                                      return 'Price can\'t be null';
                                    }
                                    setState(() {
                                      isCustomSalePriceValidated = true;
                                    });
                                    return null;
                                  },
                                ),
                                onChanged: () {
                                  setState(() {
                                    _newSalePriceFormKey.currentState
                                        ?.validate();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Expanded(
                              child: Form(
                                key: _qtyFormKey,
                                child: AventaFormField(
                                  focusNode: _qtyFocusNode,
                                  controller: _qtyController,
                                  label: "Qty",
                                  validator: (qty) {
                                    if (qty != null) {
                                      if (int.parse(qty) > widget.stockQty!) {
                                        setState(() {
                                          isQtyValidated = false;
                                        });
                                        return 'Not enough stock. Choose a lower quantity';
                                      } else if (int.parse(qty) == 0) {
                                        setState(() {
                                          isQtyValidated = false;
                                        });
                                        return 'Qty cannot be zero';
                                      }
                                    } else {
                                      setState(() {
                                        isQtyValidated = false;
                                      });
                                      return 'Qty cannot be null';
                                    }
                                    setState(() {
                                      isQtyValidated = true;
                                    });
                                    return null;
                                  },
                                  textInputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _qty = int.tryParse(value) ?? 1;
                                    });
                                    _qtyFormKey.currentState?.validate();
                                  },
                                  onCompleted: (){
                                    setState(() {
                                      _qtyFormKey.currentState?.validate();
                                      _newSalePriceFormKey.currentState?.validate();

                                      if((isQtyValidated &&
                                          isCustomSalePriceValidated &&
                                          _qty > 0)){
                                        if (widget.onAddToCart != null) {
                                          widget.onAddToCart!(
                                              widget.stock!, _qty, _salePrice);
                                        }
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                ),
                                onChanged: () {
                                  _qtyFormKey.currentState?.validate();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.sp),
                      ],
                    ),
                  ),
                ),
                // Total Amount (not scrollable)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 5.sp),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 12.sp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.08),
                          AppColors.primaryColor.withOpacity(0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: AppStyling.medium14Black.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rs. ${NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2).format(_salePrice * _qty)}',
                          style: AppStyling.semi16Black.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons (not scrollable)
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppMainButton(
                          title: "Cancel",
                          onTap: () {
                            Navigator.pop(context);
                          },
                          color: AppColors.darkGrey.withOpacity(0.15),
                          titleStyle: AppStyling.medium14Black.copyWith(
                              color: AppColors.darkGrey,
                              fontSize: 11.5.sp, height: 1),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppMainButton(
                          title: widget.isForEdit! ? "Save" : "Add to Cart",
                          titleStyle: AppStyling.medium14Black.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 11.5.sp, height: 1),
                          isEnable: (isQtyValidated &&
                              isCustomSalePriceValidated &&
                              _qty > 0),
                          onTap: () {
                            if (widget.onAddToCart != null) {
                              widget.onAddToCart!(
                                  widget.stock!, _qty, _salePrice);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
