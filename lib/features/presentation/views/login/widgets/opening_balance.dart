import 'dart:developer';
import 'dart:ui';

import 'package:AventaPOS/core/services/dependency_injection.dart';
import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_form_field.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/new_sales_tab.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_images.dart';
import '../../../../../utils/app_stylings.dart';
import '../../../../../utils/enums.dart';
import '../../../widgets/app_dialog_box.dart';
import '../../../widgets/zynolo_toast.dart';

class OpeningBalance extends BaseView {
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

class _PopupWindowState extends BaseViewState<OpeningBalance> {
  final StockBloc _bloc = inject<StockBloc>();
  final TextEditingController _openingBalController = TextEditingController();

  final FocusNode _opFocusNode = FocusNode();
  final _opFormKey = GlobalKey<FormState>();

  late double _opPrice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _openingBalController.text = '0.00';
    _opFocusNode.requestFocus();
    _opPrice = 0;
  }

  @override
  Widget buildView(BuildContext context) {
    return BlocProvider<StockBloc>(
      create: (context) => _bloc,
      child: BlocListener<StockBloc, BaseState<StockState>>(
        listener: (context, state) {
          if (state is CashInOutLoadingState) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is CashInOutSuccessState) {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.kSaleView,
              (route) => false,
            );
            ZynoloToast(
              title: state.msg,
              toastType: Toast.success,
              animationDuration: Duration(milliseconds: 500),
              toastPosition: Position.top,
              animationType: AnimationType.fromTop,
              backgroundColor: AppColors.whiteColor.withOpacity(1),
            ).show(context);
          } else if (state is CashInOutFailedState) {
            setState(() {
              _isLoading = false;
            });
            FocusManager.instance.primaryFocus?.unfocus();
            AppDialogBox.show(
              context,
              title: 'Oops..!',
              message: state.errorMsg,
              image: AppImages.failedDialog,
              isTwoButton: false,
              positiveButtonTap: () {},
              positiveButtonText: 'Try Again',
            );
          }
        },
        child: Material(
          color: AppColors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Center(
              child: Container(
                width: 55.h,
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
                        top: BorderSide(
                            color: AppColors.primaryColor, width: 10))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Content
                    Padding(
                      padding: EdgeInsets.all(3.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                              "Cashier Opening Balance",
                              textAlign: TextAlign.center,
                              style: AppStyling.medium25Black
                                  .copyWith(fontSize: 15.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 9.sp),
                            child: Text(
                              "Add opening balance to : ${AppConstants.profileData?.username} @ ${AppConstants.profileData?.location?.description}",
                              style: AppStyling.regular14Black,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 20.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Form(
                                  key: _opFormKey,
                                  child: AventaFormField(
                                    focusNode: _opFocusNode,
                                    controller: _openingBalController,
                                    label: "Opening Balance",
                                    isCurrency: true,
                                    showCurrencySymbol: true,
                                    onChanged: (value) {
                                      setState(() {
                                        log(value);
                                        // For currency fields, we need to parse the masked value
                                        if (value.isNotEmpty) {
                                          // Remove commas and parse the numeric value
                                          String cleanValue =
                                              value.replaceAll(',', '');
                                          if (cleanValue.isNotEmpty) {
                                            _opPrice =
                                                double.tryParse(cleanValue) ??
                                                    0.0;
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
                                    onCompleted: () {
                                      _bloc.add(
                                        CashInOutEvent(
                                          cashInOut: "OP",
                                          amount: _opPrice,
                                          remark: "Opening Balance",
                                        ),
                                      );
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

                          SizedBox(height: 20.sp),

                          // Action Buttons
                          AppMainButton(
                            title: "Continue",
                            titleStyle: AppStyling.medium14Black.copyWith(
                                color: AppColors.whiteColor,
                                fontSize: 12.sp, height: 1),
                            prefixIcon: _isLoading
                                ? Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        color: AppColors.whiteColor,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              _bloc.add(
                                CashInOutEvent(
                                  cashInOut: "OP",
                                  amount:
                                      _opPrice,
                                  remark: "Opening Balance",
                                ),
                              );
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
        ),
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_bloc];
  }
}
