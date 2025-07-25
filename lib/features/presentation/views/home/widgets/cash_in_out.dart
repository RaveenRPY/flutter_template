import 'dart:developer';
import 'dart:ui';

import 'package:AventaPOS/core/services/dependency_injection.dart';
import 'package:AventaPOS/features/data/models/responses/cash_in_out/view_cash_in_out.dart';
import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/widgets/cash_in_out_record.dart';
import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_form_field.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/new_sales_tab.dart';
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
import '../../../../../utils/printer_service.dart';
import '../../../widgets/app_dialog_box.dart';
import '../../../widgets/zynolo_toast.dart';

typedef CashInOutChangedCallback = void Function(
    CashMode mode, String amount, String remark);

class CashInOutWindow extends BaseView {
  const CashInOutWindow({super.key});

  @override
  State<CashInOutWindow> createState() => _CashInOutWindowState();

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
            child: CashInOutWindow(),
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

class _CashInOutWindowState extends BaseViewState<CashInOutWindow> {
  final StockBloc _bloc = inject<StockBloc>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final _remarkFormKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();

  bool _isLoadingHistory = false;
  bool _isLoadingCashInOut = false;
  bool _isAmountValidated = false;
  bool _isRemarkValidated = false;

  List<Cash>? _cashInHistory = [];
  List<Cash>? _cashOutHistory = [];

  CashMode _cashMode = CashMode.inCash;

  double _amount = 0.0;
  String? _remark = "";

  @override
  void initState() {
    super.initState();
    _amountController.text = '0.00';
    _bloc.add(ViewTodayCashInOutEvent());
    _amountFocusNode.requestFocus();
  }

  @override
  Future<void> didChangeDependencies() async {
    // Discover printers
    final printers = await PrinterService.instance.discoverUsbPrinters();
    // Connect to a printer
    await PrinterService.instance.connectUsbPrinter(printers[0]);
    super.didChangeDependencies();
  }

  @override
  Widget buildView(BuildContext context) {
    return BlocProvider<StockBloc>(
      create: (context) => _bloc,
      child: BlocListener<StockBloc, BaseState<StockState>>(
        listener: (context, state) async {
          if (state is ViewTodayCashInOutLoadingState) {
            setState(() {
              _isLoadingHistory = true;
            });
          } else if (state is ViewTodayCashInOutSuccessState) {
            setState(() {
              _isLoadingHistory = false;
              _cashInHistory = state.dataList
                  ?.where(
                    (element) => (element.cashInOut == "IN" ||
                        element.cashInOut == "OP"),
                  )
                  .toList();
              _cashOutHistory = state.dataList
                  ?.where(
                    (element) => element.cashInOut == "OUT",
                  )
                  .toList();
            });
            // Open cash drawer
            await PrinterService.instance.openCashDrawer();
          } else if (state is ViewTodayCashInOutFailedState) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              _isLoadingHistory = false;
            });
            AppDialogBox.show(
              context,
              title: 'Oops..!',
              message: state.errorMsg,
              image: AppImages.failedDialog,
              isTwoButton: false,
              positiveButtonTap: () {},
              positiveButtonText: 'Try Again',
            );
          } else if (state is CashInOutLoadingState) {
            setState(() {
              _isLoadingCashInOut = true;
            });
          } else if (state is CashInOutSuccessState) {
            setState(() {
              _isLoadingCashInOut = false;
            });
            ZynoloToast(
              title: state.msg,
              toastType: Toast.success,
              animationDuration: Duration(milliseconds: 500),
              toastPosition: Position.top,
              animationType: AnimationType.fromTop,
              backgroundColor: AppColors.whiteColor.withOpacity(1),
            ).show(context);
            Navigator.pop(context);
          } else if (state is CashInOutFailedState) {
            setState(() {
              _isLoadingCashInOut = false;
            });
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
          surfaceTintColor: AppColors.transparent,
          color: AppColors.darkBlue.withOpacity(0.1),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Center(
              child: Container(
                width: 45.w,
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
                      padding: EdgeInsets.fromLTRB(15.sp, 15.sp, 15.sp, 15.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _cashMode == CashMode.inCash
                                          ? "Cash In"
                                          : "Cash Out",
                                      style: AppStyling.medium25Black
                                          .copyWith(fontSize: 32),
                                    ),
                                    Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ChoiceChip(
                                          label: Text("Cash In"),
                                          selectedColor: AppColors.primaryColor,
                                          selected:
                                              _cashMode == CashMode.inCash,
                                          onSelected: (selected) {
                                            setState(() {
                                              _cashMode = CashMode.inCash;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        ChoiceChip(
                                          label: Text("Cash Out"),
                                          selectedColor: AppColors.primaryColor,
                                          selected:
                                              _cashMode == CashMode.outCash,
                                          onSelected: (selected) {
                                            setState(() {
                                              _cashMode = CashMode.outCash;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 35),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Form(
                                key: _amountFormKey,
                                child: AventaFormField(
                                  focusNode: _amountFocusNode,
                                  controller: _amountController,
                                  label: "Amount",
                                  isCurrency: true,
                                  showCurrencySymbol: true,
                                  onChanged: (value) {
                                    setState(() {
                                      _amountFormKey.currentState?.validate();
                                      _amount = double.parse(
                                          value.replaceAll(',', ''));
                                    });
                                  },
                                  validator: (price) {
                                    if (price != null) {
                                      if (double.parse(
                                              price.replaceAll(',', '')) >
                                          0) {
                                        setState(() {
                                          _isAmountValidated = true;
                                        });
                                      } else {
                                        setState(() {
                                          _isAmountValidated = false;
                                        });
                                        return 'Price can\'t be zero';
                                      }
                                    } else {
                                      setState(() {
                                        _isAmountValidated = false;
                                      });
                                      return 'Price can\'t be null';
                                    }
                                    setState(() {
                                      _isAmountValidated = false;
                                    });
                                    return null;
                                  },
                                  onCompleted: () {
                                    if (_amount > 0) {
                                      _bloc.add(
                                        CashInOutEvent(
                                          cashInOut:
                                              _cashMode == CashMode.inCash
                                                  ? "IN"
                                                  : "OUT",
                                          amount: _amount,
                                          remark: _remarkController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                onChanged: () {
                                  setState(() {
                                    _amountFormKey.currentState?.validate();
                                  });
                                },
                              ),
                              SizedBox(
                                height: 13.sp,
                              ),
                              Form(
                                key: _remarkFormKey,
                                child: AventaFormField(
                                  controller: _remarkController,
                                  label: "Remark",
                                  onChanged: (value) {
                                    setState(() {
                                      _remarkFormKey.currentState?.validate();
                                      _remark = value;
                                    });
                                  },
                                  validator: (remark) {
                                    if (remark != null) {
                                      setState(() {
                                        _remark = remark;
                                        _isRemarkValidated = true;
                                      });
                                    } else {
                                      setState(() {
                                        _isRemarkValidated = true;
                                      });
                                      return 'Remark can\'t be empty';
                                    }
                                    setState(() {
                                      _isAmountValidated = false;
                                    });
                                    return null;
                                  },
                                  onCompleted: () {
                                    _remarkFormKey.currentState?.validate();
                                    _amountFormKey.currentState?.validate();

                                    if (_amount > 0 && _remark != "") {
                                      _bloc.add(
                                        CashInOutEvent(
                                          cashInOut:
                                              _cashMode == CashMode.inCash
                                                  ? "IN"
                                                  : "OUT",
                                          amount: _amount,
                                          remark: _remarkController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.sp),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: AppMainButton(
                                  title: "Cancel",
                                  isNegative: true,
                                  color: AppColors.darkGrey.withOpacity(0.15),
                                  titleStyle: AppStyling.medium14Black.copyWith(
                                      color: AppColors.darkBlue,
                                      fontSize: 11.5.sp,
                                      height: 1),
                                  onTap: () {
                                    if (_isLoadingCashInOut) {
                                      ZynoloToast(
                                        title:
                                            "Your request is currently being processed",
                                        toastType: Toast.warning,
                                        animationDuration:
                                            Duration(milliseconds: 500),
                                        toastPosition: Position.top,
                                        animationType: AnimationType.fromTop,
                                        backgroundColor:
                                            AppColors.whiteColor.withOpacity(1),
                                      ).show(context);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: AppMainButton(
                                  title: "Save",
                                  titleStyle: AppStyling.medium14Black.copyWith(
                                      color: AppColors.whiteColor,
                                      fontSize: 11.5.sp,
                                      height: 1),
                                  prefixIcon: _isLoadingCashInOut
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
                                  isEnable: _amount > 0 && _remark != "",
                                  onTap: () {
                                    // Navigator.pop(context);
                                    _amountFormKey.currentState?.validate();
                                    _remarkFormKey.currentState?.validate();
                                    _bloc.add(
                                      CashInOutEvent(
                                          cashInOut:
                                              _cashMode == CashMode.inCash
                                                  ? "IN"
                                                  : "OUT",
                                          amount: _amount,
                                          remark: _remarkController.text),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Divider(
                            thickness: 2,
                            color: AppColors.darkGrey.withOpacity(0.1),
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.4),
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Date",
                                            textAlign: TextAlign.center,
                                            style: AppStyling.semi12Black,
                                          )),
                                          Expanded(
                                              child: Text(
                                            "Time",
                                            textAlign: TextAlign.center,
                                            style: AppStyling.semi12Black,
                                          )),
                                          Expanded(
                                              child: Text(
                                            "Remark",
                                            textAlign: TextAlign.center,
                                            style: AppStyling.semi12Black,
                                          )),
                                          Expanded(
                                              child: Text(
                                            "Amount (Rs)",
                                            textAlign: TextAlign.center,
                                            style: AppStyling.semi12Black,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (!_isLoadingHistory)
                                    if (_cashMode == CashMode.inCash
                                        ? _cashInHistory!.isNotEmpty
                                        : _cashOutHistory!.isNotEmpty)
                                      ListView.builder(
                                        itemCount: _cashMode == CashMode.inCash
                                            ? _cashInHistory?.length
                                            : _cashOutHistory?.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          Cash item =
                                              _cashMode == CashMode.inCash
                                                  ? _cashInHistory![index]
                                                  : _cashOutHistory![index];
                                          return CashInOutRecord(
                                            date: item.date ?? DateTime.now(),
                                            remark: item.remark ?? "N/A",
                                            amount: item.amount ?? 0,
                                            isLast: (_cashMode ==
                                                            CashMode.inCash
                                                        ? _cashInHistory
                                                        : _cashOutHistory)
                                                    ?.last ==
                                                (_cashMode == CashMode.inCash
                                                    ? _cashInHistory![index]
                                                    : _cashOutHistory![index]),
                                          );
                                        },
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.darkGrey
                                              .withOpacity(0.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "No cash in/out records for today",
                                                style: AppStyling.regular12Grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  else
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.darkGrey.withOpacity(0.0),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
        ),
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_bloc];
  }
}
