import 'dart:async';
import 'dart:developer';

import 'package:AventaPOS/core/services/dependency_injection.dart';
import 'package:AventaPOS/features/data/models/requests/checkout.dart';
import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/data/sales_invoice_data.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/widgets/bill_preview_widget.dart';
import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_form_field.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/app_stylings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart'
    hide
        CapabilityProfile,
        Generator,
        PaperSize,
        PosStyles,
        PosAlign,
        PosTextSize;
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/printer_service.dart';
import '../../../data/models/responses/sale/get_stock.dart';
import '../../widgets/app_dialog_box.dart';
import '../../widgets/zynolo_toast.dart';

class ProcessPaymentView extends BaseView {
  final PaymentParams params;

  const ProcessPaymentView({super.key, required this.params});

  @override
  State<ProcessPaymentView> createState() => _ProcessPaymentViewState();
}

class _ProcessPaymentViewState extends BaseViewState<ProcessPaymentView> {
  final StockBloc _bloc = inject<StockBloc>();
  final TextEditingController _customerPaidController = TextEditingController();
  double _customerPaid = 0.0;
  String _paymentType = 'Cash';
  List<BillingItem> _billingItemList = [];

  SalesInvoiceData invoiceData = SalesInvoiceData();

  final FocusNode _focusNode = FocusNode();

  // Add printing status tracking
  String _printingStatus = '';
  bool _isPrinting = false;
  bool _printingCompleted = false;

  ///-----------------------------------------------------------------------------------------
  final PrinterManager _printerManager = PrinterManager.instance;
  List<PrinterDevice> _devices = [];
  PrinterDevice? _selectedPrinter;

  ///-----------------------------------------------------------------------------------------

  // Get Printer List
  // void startScan() async {
  //   _devicesStreamSubscription?.cancel();
  //   await _flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
  //     ConnectionType.NETWORK,
  //   ]);
  //   _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
  //       .listen((List<Printer> event) {
  //     log(event.map((e) => e.name).toList().toString());
  //     setState(() {
  //       printers = event;
  //       printers.removeWhere(
  //           (element) => element.name == null || element.name == '');
  //     });
  //   });
  // }
  //
  // stopScan() {
  //   _flutterThermalPrinterPlugin.stopScan();
  // }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);
  }

  // Handle printing with status updates
  Future<void> _handlePrinting({
    required List<Stock> itemList,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String cashier,
    required String paymentType,
    required String outlet,
    required String total,
    required String cash,
    required String changes,
  }) async {
    setState(() {
      _isPrinting = true;
      _printingStatus = 'Attempting to print receipt...';
    });

    try {
      await PrinterService.instance.printBill(
        itemList: itemList,
        invoiceNo: invoiceNo,
        invoiceDate: invoiceDate,
        cashier: cashier,
        paymentType: paymentType,
        outlet: outlet,
        total: total,
        cash: cash,
        changes: changes,
        isRetail: widget.params.isRetail ?? true,
      );
      
      setState(() {
        _printingStatus = 'Receipt printed successfully!';
        _printingCompleted = true;
      });
    } catch (e) {
      setState(() {
        _printingStatus = 'Printing failed: ${e.toString()}';
        _printingCompleted = true;
      });
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  // Retry printing using saved receipt data
  Future<void> _retryPrinting() async {
    setState(() {
      _isPrinting = true;
      _printingStatus = 'Retrying to print receipt...';
      _printingCompleted = false;
    });

    try {
      await PrinterService.instance.retryLastReceipt();
      
      setState(() {
        _printingStatus = 'Receipt printed successfully!';
        _printingCompleted = true;
      });
    } catch (e) {
      setState(() {
        _printingStatus = 'Printing failed: ${e.toString()}';
        _printingCompleted = true;
      });
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  // Update stock quantities after successful sale
  void _updateStockQuantities(List<Stock> soldItems) {
    if (AppConstants.stockList == null) return;
    
    final updatedStockList = List<Stock>.from(AppConstants.stockList!);
    log('Updating stock quantities for ${soldItems.length} items');
    
    for (final soldItem in soldItems) {
      final soldQty = soldItem.cartQty ?? 0;
      if (soldQty > 0) {
        // Find the corresponding stock item and update its quantity
        final stockIndex = updatedStockList.indexWhere(
          (stock) => stock.id == soldItem.id
        );
        
        if (stockIndex != -1) {
          final currentStock = updatedStockList[stockIndex];
          final newQty = (currentStock.qty ?? 0) - soldQty;
          
          log('Updated stock: ${currentStock.item?.description} - Old: ${currentStock.qty}, Sold: $soldQty, New: $newQty');
          
          updatedStockList[stockIndex] = Stock(
            id: currentStock.id,
            item: currentStock.item,
            labelPrice: currentStock.labelPrice,
            itemCost: currentStock.itemCost,
            retailPrice: currentStock.retailPrice,
            wholesalePrice: currentStock.wholesalePrice,
            retailDiscount: currentStock.retailDiscount,
            wholesaleDiscount: currentStock.wholesaleDiscount,
            qty: newQty,
            status: currentStock.status,
            statusDescription: currentStock.statusDescription,
            cartQty: currentStock.cartQty,
          );
        } else {
          log('Stock item not found for ID: ${soldItem.id}');
        }
      }
    }
    
    // Update the global stock list
    AppConstants.stockList = updatedStockList;
    log('Stock list updated successfully. Total items: ${AppConstants.stockList?.length}');
  }

  @override
  void dispose() {
    // _customerPaidController.dispose();
    super.dispose();
  }

  List<BillingItem> convertStockToBillingItems(List<Stock> stocks) {

    return stocks
        .map((stock) {
          log((stock.item?.code == "ITEM_1459").toString());
          return BillingItem(
              qty: stock.cartQty ?? stock.qty,
              salesPrice: stock.retailPrice,
              salesDiscount: 0,
              stock: stock.id,
              other: stock.item?.code == "ITEM_1459",
            );
        })
        .toList();
  }

  // // Scan for USB printers
  // void _scanForPrinters() {
  //   _printerManager.discovery(type: PrinterType.usb).listen((device) {
  //     setState(() {
  //       _devices.add(device);
  //       log("----Printers - $_devices");
  //     });
  //   });
  //   // _connectDevice(_devices[0]);
  // }

  // // Connect to the selected USB printer
  // Future<void> _connectDevice(PrinterDevice device) async {
  //   await _printerManager.connect(
  //     type: PrinterType.usb,
  //     model: UsbPrinterInput(
  //       name: device.name,
  //       productId: device.productId,
  //       vendorId: device.vendorId,
  //     ),
  //   );
  //   setState(() {
  //     _selectedPrinter = device;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _customerPaidController.text = "0.00";
    _focusNode.requestFocus();
    _billingItemList = convertStockToBillingItems(widget.params.cartItemList);
  }

  @override
  void didChangeDependencies() async {
    // Discover printers
    final printers = await PrinterService.instance.discoverUsbPrinters();
    // Connect to a printer
    await PrinterService.instance.connectUsbPrinter(printers[0]);
    super.didChangeDependencies();
  }

  // void printBill({
  //   required List<Stock> itemList,
  //   required String invoiceNo,
  //   required DateTime invoiceDate,
  //   required String cashier,
  //   required String paymentType,
  //   required String outlet,
  //   required String total,
  //   required String cash,
  //   required String changes,
  // }) async {
  //   if (_selectedPrinter == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No printer selected')),
  //     );
  //     return;
  //   }
  //
  //   final bytes = await _generateReceipt(
  //     itemList: itemList,
  //     invoiceNo: invoiceNo,
  //     invoiceDate: invoiceDate,
  //     cashier: cashier,
  //     paymentType: paymentType,
  //     outlet: outlet,
  //     total: total,
  //     cash: cash,
  //     changes: changes,
  //   );
  //   await _printerManager.send(type: PrinterType.usb, bytes: bytes);
  //   // await _printerManager.disconnect(type: PrinterType.usb);
  // }

  @override
  Widget buildView(BuildContext context) {
    final grandTotal = widget.params.total;
    final change = _customerPaid - grandTotal;
    final itemList = widget.params.cartItemList;

    return BlocProvider<StockBloc>(
      create: (context) => _bloc,
      child: BlocListener<StockBloc, BaseState<StockState>>(
        listener: (context, state) async {
          if (state is CheckoutSuccessState) {
            setState(() {
              invoiceData.paymentType = state.response?.paymentTypeDescription;
              invoiceData.invoiceNo = state.response?.invoiceNumber;
              invoiceData.invoiceDate = state.response?.invoiceDate;
              invoiceData.outlet = state.response?.outletName;
              invoiceData.counter = state.response?.counter;
              invoiceData.itemList = itemList;
              invoiceData.total = _formatCurrency(grandTotal);
              invoiceData.cash = _formatCurrency(_customerPaid);
              invoiceData.changes = _formatCurrency(change);
            });

            // Handle printing in background without blocking checkout
            _handlePrinting(
              itemList: itemList,
              invoiceNo: state.response?.invoiceNumber ?? '',
              invoiceDate: state.response?.invoiceDate ?? DateTime.now(),
              cashier: state.response?.counter ?? '',
              paymentType: state.response?.paymentTypeDescription ?? '',
              outlet: state.response?.outletName ?? '',
              total: grandTotal.toString(),
              cash: _customerPaid.toString(),
              changes: change.toString(),
            );

            // Update stock quantities after successful sale
            _updateStockQuantities(itemList);

            ZynoloToast(
              title: state.msg,
              toastType: Toast.success,
              animationDuration: Duration(milliseconds: 500),
              toastPosition: Position.top,
              animationType: AnimationType.fromTop,
              backgroundColor: AppColors.whiteColor.withOpacity(1),
            ).show(context);

            // Show printing status dialog
            if (_printingCompleted) {
              // _showPrintingStatusDialog();
            }
            await Future.delayed(Duration(seconds: 2), () {
              setState(() {
                widget.params.onPop!(true);
              });
            });
          } else if (state is CheckoutFailedState) {
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
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20.sp,
                    child: Material(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(60),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(60),
                        splashColor: AppColors.darkBlue.withOpacity(0.1),
                        highlightColor: AppColors.darkBlue.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            widget.params.onPop!(false);
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13.sp,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  Text(
                    "Proceed Payment",
                    style: AppStyling.medium16Black,
                  ),
                  // Add printing status indicator
                  if (_printingStatus.isNotEmpty) ...[
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                      decoration: BoxDecoration(
                        color: _printingCompleted 
                            ? (_printingStatus.contains('successfully') 
                                ? AppColors.lightGreen.withOpacity(0.2)
                                : AppColors.red.withOpacity(0.2))
                            : AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _printingCompleted 
                              ? (_printingStatus.contains('successfully') 
                                  ? AppColors.lightGreen
                                  : AppColors.red)
                              : AppColors.primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isPrinting)
                            SizedBox(
                              width: 12.sp,
                              height: 12.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _printingCompleted 
                                      ? (_printingStatus.contains('successfully') 
                                          ? AppColors.lightGreen
                                          : AppColors.red)
                                      : AppColors.primaryColor,
                                ),
                              ),
                            ),
                          if (_isPrinting) SizedBox(width: 6.sp),
                          Text(
                            _printingStatus,
                            style: AppStyling.medium12Black.copyWith(
                              fontSize: 10.sp,
                              color: _printingCompleted 
                                  ? (_printingStatus.contains('successfully') 
                                      ? AppColors.lightGreen
                                      : AppColors.red)
                                  : AppColors.primaryColor,
                            ),
                          ),
                          // Add retry button for failed printing
                          if (_printingCompleted && !_printingStatus.contains('successfully')) ...[
                            SizedBox(width: 8.sp),
                            GestureDetector(
                              onTap: () {
                                _retryPrinting();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Retry',
                                  style: AppStyling.medium12Black.copyWith(
                                    fontSize: 8.sp,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(
                height: 10.sp,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.whiteColor),
                        child: ReceiptPreview(
                          cash: _customerPaid.toString(),
                          cashier: "Cashier Name",
                          changes: change.toString(),
                          invoiceDate: DateTime.now(),
                          invoiceNo: "XXXXXXXXXX",
                          isRetail: widget.params.isRetail ?? true,
                          outlet: AppConstants
                              .profileData!.location!.description
                              .toString(),
                          paymentType: "Cash",
                          total: grandTotal.toString(),
                          itemList: itemList,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkGrey.withOpacity(0.07),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Grand Total',
                                style: AppStyling.medium14Black),
                            SizedBox(height: 6),
                            Text(
                              _formatCurrency(grandTotal),
                              style:
                                  AppStyling.bold18Black.copyWith(fontSize: 28),
                            ),
                            Divider(
                                height: 32,
                                thickness: 1,
                                color: AppColors.lineSeparationColor),
                            Text('Customer Paid',
                                style: AppStyling.medium14Black),
                            SizedBox(height: 6),
                            AventaFormField(
                              controller: _customerPaidController,
                              focusNode: _focusNode,
                              isCurrency: true,
                              showCurrencySymbol: true,
                              textInputType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  _customerPaid = double.tryParse(
                                          val.replaceAll(',', '')) ??
                                      0.0;
                                });
                              },
                              onCompleted: (_customerPaid >= grandTotal)
                                  ? () {
                                      _bloc.add(CheckOutEvent(
                                          remark: "",
                                          salesType: widget.params.isRetail!
                                              ? "NORMAL"
                                              : "WHOLESALE",
                                          paymentType: "CASH",
                                          totalAmount: grandTotal,
                                          payAmount: _customerPaid,
                                          billingItem: _billingItemList));
                                    }
                                  : () {
                                      AppDialogBox.show(
                                        context,
                                        title: 'Sorry!',
                                        message:
                                            'Cash customer can\'t process any credit payments',
                                        image: AppImages.failedDialog,
                                        isTwoButton: false,
                                        positiveButtonText: 'Okay',
                                        positiveButtonTap: () {},
                                      );
                                    },
                            ),
                            SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Change to Return',
                                    style: AppStyling.medium14Black),
                                Text(
                                  _formatCurrency(change),
                                  style: AppStyling.semi14Black.copyWith(
                                    color:
                                        change < 0 ? Colors.red : Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                                height: 32,
                                thickness: 1,
                                color: AppColors.lineSeparationColor),
                            Text('Payment Type',
                                style: AppStyling.medium14Black),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'Cash',
                                    groupValue: _paymentType,
                                    onChanged: (val) {
                                      setState(() {
                                        _paymentType = val!;
                                      });
                                    },
                                    title: Text('Cash',
                                        style: AppStyling.medium12Black),
                                    activeColor: AppColors.primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'Card',
                                    groupValue: _paymentType,
                                    onChanged: (val) {
                                      setState(() {
                                        _paymentType = val!;
                                      });
                                    },
                                    title: Text('Card',
                                        style: AppStyling.medium12Black),
                                    activeColor: AppColors.primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: AppMainButton(
                                    title: 'Complete Payment',
                                    titleStyle: AppStyling.medium14Black
                                        .copyWith(
                                            color: AppColors.whiteColor,
                                            fontSize: 11.5.sp,
                                            height: 1),
                                    onTap: (_customerPaid >= grandTotal)
                                        ? () {
                                            _bloc.add(CheckOutEvent(
                                                remark: "",
                                                salesType:
                                                    widget.params.isRetail!
                                                        ? "NORMAL"
                                                        : "WHOLESALE",
                                                paymentType: "CASH",
                                                totalAmount: grandTotal,
                                                payAmount: _customerPaid,
                                                billingItem: _billingItemList));
                                          }
                                        : () {
                                            AppDialogBox.show(
                                              context,
                                              title: 'Sorry!',
                                              message:
                                                  'Cash customer can\'t process any credit payments',
                                              image: AppImages.failedDialog,
                                              isTwoButton: false,
                                              positiveButtonText: 'Okay',
                                              positiveButtonTap: () {},
                                            );
                                          },
                                  ),
                                ),
                              ],
                            )
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
    );
  }

  // Show printing status dialog
  void _showPrintingStatusDialog() {
    if (!_printingCompleted) return;
    
    final isSuccess = _printingStatus.contains('successfully');
    final title = isSuccess ? 'Printing Successful' : 'Printing Failed';
    final message = isSuccess 
        ? 'Receipt has been printed successfully.'
        : 'Receipt printing failed. You can retry printing from the settings.';
    final image = isSuccess ? AppImages.successDialog : AppImages.failedDialog;
    
    AppDialogBox.show(
      context,
      title: title,
      message: message,
      image: image,
      isTwoButton: !isSuccess, // Show two buttons only for failure
      negativeButtonText: isSuccess ? null : 'Retry',
      negativeButtonTap: isSuccess ? null : () {
        // Retry printing
        _retryPrinting();
      },
      positiveButtonText: 'OK',
      positiveButtonTap: () {},
    );
  }

  Future<List<int>> _generateReceipt({
    required List<Stock> itemList,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String cashier,
    required String paymentType,
    required String outlet,
    required String total,
    required String cash,
    required String changes,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.drawer();

    log("----- $itemList");
    int totalItems = 0;
    // Header
    bytes += generator.text(
      'DPD Chemical',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text('');

    bytes += generator.text(
      outlet,
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      "076 891 85 70 / 078 60 65 410",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text('');
    bytes += generator.text(
      widget.params.isRetail! ? 'SALES INVOICE' : 'WHOLESALE INVOICE',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();
    // Invoice metadata
    bytes += generator.text(
        'Date       : ${DateFormat('yyyy-MM-dd hh:mm:ss a').format(invoiceDate)}');
    bytes += generator.text('Invoice No : $invoiceNo');
    bytes += generator.text('Outlet     : $outlet');
    bytes += generator.text('Payment    : $paymentType');
    bytes += generator.hr();
    // Table header
    bytes += generator.text(
      'No  Item Name            Price     Qty    Total',
      styles: PosStyles(bold: true),
    );
    bytes += generator.hr();
    for (var i = 0; i < itemList.length; i++) {
      final item = itemList[i];
      totalItems += item.cartQty as int;
      final name = item.item?.description ?? '';
      final priceStr = (item.retailPrice ?? 0).toString().padRight(10);
      final qtyStr = (item.cartQty.toString()).padRight(5);
      final totalStr =
          ((item.cartQty ?? 0) * (item.retailPrice ?? 0)).toString();

      if (name.length > 18) {
        final firstLine = '${(i + 1).toString().padRight(4)}'
            '${name.substring(0, 18).padRight(22)}'
            '$priceStr'
            '$qtyStr'
            '$totalStr';
        final secondLine = '    ' // 4 spaces for No
            '${name.substring(18).padRight(22)}';
        bytes += generator.text(firstLine);
        bytes += generator.text(secondLine);
      } else {
        final line = '${(i + 1).toString().padRight(4)}'
            '${name.padRight(22)}'
            '$priceStr'
            '$qtyStr'
            '$totalStr';
        bytes += generator.text(line);
      }
    }
    // Total
    bytes += generator.hr();
    bytes += generator.text(
      'TOTAL ITEMS    :   $totalItems',
      styles: PosStyles(bold: true),
    );
    bytes += generator.hr();
    bytes += generator.text('Total Amount : $total',
        styles: PosStyles(align: PosAlign.right));
    bytes += generator.text('Cash : $cash',
        styles: PosStyles(align: PosAlign.right));
    bytes += generator.text('Changes : $changes',
        styles: PosStyles(align: PosAlign.right));
    bytes += generator.hr();
    // Notes
    bytes += generator.text('');
    bytes += generator.text(
      'NOTES:',
      styles: PosStyles(bold: true),
    );
    bytes += generator.text('Please verify items upon receipt.');
    bytes += generator.text('Report any missing/damaged items within 24hrs.');
    bytes += generator.text('');
    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      'Thank You !',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();
    bytes += generator.text('');
    // Powered by
    bytes += generator.text(
      'Powered By AventaPOS',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }

  Widget receiptWidget(String printerType) {
    return SizedBox(
      width: 550,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'FLUTTER THERMAL PRINTER',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              _buildReceiptRow('Item', 'Price'),
              const Divider(),
              _buildReceiptRow('Apple', '\$1.00'),
              _buildReceiptRow('Banana', '\$0.50'),
              _buildReceiptRow('Orange', '\$0.75'),
              const Divider(thickness: 2),
              _buildReceiptRow('Total', '\$2.25', isBold: true),
              const SizedBox(height: 20),
              _buildReceiptRow('Printer Type', printerType),
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  'Thank you for your purchase!',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String leftText, String rightText,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            rightText,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_bloc];
  }
}

class PaymentParams {
  final List<Stock> cartItemList;
  final double total;
  final Function? onPop;
  final bool? isRetail;

  PaymentParams(
      {required this.cartItemList,
      required this.total,
      this.onPop,
      this.isRetail});
}
