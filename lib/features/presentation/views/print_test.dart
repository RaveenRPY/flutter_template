import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:thermal_printer/thermal_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const PrinterScreen(),
    );
  }
}

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({Key? key}) : super(key: key);

  @override
  _PrinterScreenState createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final PrinterManager _printerManager = PrinterManager.instance;
  List<PrinterDevice> _devices = [];
  PrinterDevice? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _scanForPrinters();
  }

  // Scan for USB printers
  void _scanForPrinters() {
    _printerManager.discovery(type: PrinterType.usb).listen((device) {
      setState(() {
        _devices.add(device);
        log("----Printers - $_devices");
      });
    });
  }

  // Connect to the selected USB printer
  Future<void> _connectDevice(PrinterDevice device) async {
    await _printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        name: device.name,
        productId: device.productId,
        vendorId: device.vendorId,
      ),
    );
    setState(() {
      _selectedPrinter = device;
      log("----Printers - $_selectedPrinter");
    });
  }

  // Print sample text
  Future<void> _printText() async {
    if (_selectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer selected')),
      );
      return;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Add text to print
    bytes += generator.text(
      'Hello, World!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text('This is a test print');
    bytes += generator.feed(2); // Feed two lines
    bytes += generator.drawer(); // Feed two lines
    bytes += generator.cut(); // Cut the paper

    // Send print data to the printer
    await _printerManager.send(type: PrinterType.usb, bytes: bytes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print command sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USB Thermal Printer')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].name ?? 'Unknown Printer'),
                  subtitle: Text(_devices[index].vendorId ?? 'No Vendor ID'),
                  onTap: () => _connectDevice(_devices[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _printText,
            child: const Text('Print Test Ticket'),
          ),
        ],
      ),
    );
  }
}