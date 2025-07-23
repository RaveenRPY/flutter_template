import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

class SalesInvoiceData {
  String? outlet;
  String? contactNumbers;
  String? invoiceNo;
  String? counter;
  DateTime? invoiceDate;
  String? paymentType;
  List<Stock>? itemList;
  String? total;
  String? cash;
  String? changes;

  SalesInvoiceData(
      {this.outlet,
      this.contactNumbers,
      this.invoiceNo,
      this.counter,
      this.invoiceDate,
      this.paymentType,
      this.itemList,
      this.total,
      this.cash,
      this.changes});
}
