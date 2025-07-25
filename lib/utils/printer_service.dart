import 'dart:async';
import 'dart:developer';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:thermal_printer/thermal_printer.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart' hide CapabilityProfile, Generator, PaperSize, PosStyles, PosAlign, PosTextSize;
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:intl/intl.dart';
import '../features/data/models/responses/sale/get_stock.dart';

class PrinterService {
  PrinterService._privateConstructor();
  static final PrinterService instance = PrinterService._privateConstructor();

  final PrinterManager _printerManager = PrinterManager.instance;
  List<PrinterDevice> _devices = [];
  PrinterDevice? _selectedPrinter;

  // Discover USB printers
  Future<List<PrinterDevice>> discoverUsbPrinters() async {
    _devices = [];
    final completer = Completer<List<PrinterDevice>>();
    _printerManager.discovery(type: PrinterType.usb).listen((device) {
      _devices.add(device);
      log("Discovered printer: "+device.name);
    },
    onDone: () => completer.complete(_devices),
    onError: (e) => completer.completeError(e));
    return completer.future;
  }

  // Connect to a USB printer
  Future<void> connectUsbPrinter(PrinterDevice device) async {
    await _printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        name: device.name,
        productId: device.productId,
        vendorId: device.vendorId,
      ),
    );
    _selectedPrinter = device;
  }

  // Print a bill (receipt)
  Future<void> printBill({
    required List<Stock> itemList,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String cashier,
    required String paymentType,
    required String outlet,
    required String total,
    required String cash,
    required String changes,
    required bool isRetail,
  }) async {
    if (_selectedPrinter == null) {
      throw Exception('No printer selected');
    }
    final bytes = await generateReceipt(
      itemList: itemList,
      invoiceNo: invoiceNo,
      invoiceDate: invoiceDate,
      cashier: cashier,
      paymentType: paymentType,
      outlet: outlet,
      total: total,
      cash: cash,
      changes: changes,
      isRetail: isRetail,
    );
    await _printerManager.send(type: PrinterType.usb, bytes: bytes);
  }

  // Open cash drawer
  Future<void> openCashDrawer() async {
    if (_selectedPrinter == null) {
      throw Exception('No printer selected');
    }
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = generator.drawer();
    await _printerManager.send(type: PrinterType.usb, bytes: bytes);
  }

  // Generate receipt bytes
  Future<List<int>> generateReceipt({
    required List<Stock> itemList,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String cashier,
    required String paymentType,
    required String outlet,
    required String total,
    required String cash,
    required String changes,
    required bool isRetail,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.drawer();
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
      isRetail ? 'SALES INVOICE' : 'WHOLESALE INVOICE',
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
      final totalStr = ((item.cartQty ?? 0) * (item.retailPrice ?? 0)).toString();
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

  // Optionally, expose selected printer for UI
  PrinterDevice? get selectedPrinter => _selectedPrinter;
  List<PrinterDevice> get availableDevices => _devices;
}
