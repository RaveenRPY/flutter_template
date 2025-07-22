import 'dart:ui';

import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_form_field.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/new_sales_tab.dart';
import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_stylings.dart';

class OpeningBalance extends StatefulWidget {
  const OpeningBalance({super.key});

  @override
  State<OpeningBalance> createState() => _PopupWindowState();

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: true,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: OpeningBalance(),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
    );
  }
}

class _PopupWindowState extends State<OpeningBalance> {
  final TextEditingController _openingBalController = TextEditingController();

  final FocusNode _opFocusNode = FocusNode();
  final _opFormKey = GlobalKey<FormState>();

  late double _opPrice;

  @override
  void initState() {
    super.initState();
    _openingBalController.text = '0.00';

    _opFocusNode.requestFocus();

    _opPrice = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            width: 25.w,
            constraints: BoxConstraints(maxWidth: 85.w, maxHeight: 70.h),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compact Content
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 5, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          "Cashier Opening Balance",
                          style:
                              AppStyling.medium25Black.copyWith(fontSize: 26),
                        ),
                      ),

                      SizedBox(height: 60),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Form(
                              key: _opFormKey,
                              child: AventaFormField(
                                controller: _openingBalController,
                                label: "Opening Balance",
                                isCurrency: true,
                                showCurrencySymbol: true,
                                onChanged: (value) {
                                  setState(() {
                                    // For currency fields, we need to parse the masked value
                                    if (value.isNotEmpty) {
                                      // Remove commas and parse the numeric value
                                      String cleanValue =
                                          value.replaceAll(',', '');
                                      if (cleanValue.isNotEmpty) {
                                        _opPrice =
                                            double.tryParse(cleanValue) ?? 0.0;
                                      }
                                    }
                                  });
                                },
                                validator: (price) {
                                  if (price != null) {
                                  } else {
                                    return 'Price can\'t be null';
                                  }
                                  return null;
                                },
                              ),
                              onChanged: () {
                                setState(() {
                                  // _newSalePriceFormKey.currentState?.validate();
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      SizedBox(height: 2.5.h),

                      // Action Buttons
                      AppMainButton(
                        title: "Continue",
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, Routes.kSaleView);
                        },
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
