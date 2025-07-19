import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'core/my_app.dart';
import 'core/services/dependency_injection.dart' as di;
import 'utils/app_colors.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.whiteColor,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await di.setupLocator();

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(
              context,
            ).textScaleFactor.clamp(0.5, 1.4),
          ),
          child: const MyApp(),
        );
      },
    ),
  );
}

class NewSaleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is the New Sale View!'), // Replace with your real UI
    );
  }
}

class Product {
  final String name;
  final String code;
  final double labelPrice;
  final int qty;
  final double salePrice;

  Product({
    required this.name,
    required this.code,
    required this.labelPrice,
    required this.qty,
    required this.salePrice,
  });
}

class ProductDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  ProductDataSource(List<Product> products) {
    _rows = products.map<DataGridRow>((product) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: product.name),
        DataGridCell<String>(columnName: 'code', value: product.code),
        DataGridCell<double>(columnName: 'labelPrice', value: product.labelPrice),
        DataGridCell<int>(columnName: 'qty', value: product.qty),
        DataGridCell<double>(columnName: 'salePrice', value: product.salePrice),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.blueGrey[50],
      cells: row.getCells().asMap().entries.map<Widget>((entry) {
        final idx = entry.key;
        final cell = entry.value;
        final isSalePrice = cell.columnName == 'salePrice';
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          alignment: idx == 0 ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            cell.value is double
                ? (cell.columnName == 'labelPrice' || cell.columnName == 'salePrice')
                    ? cell.value.toStringAsFixed(2)
                    : cell.value.toString()
                : cell.value.toString(),
            style: TextStyle(
              fontWeight: idx == 0 ? FontWeight.bold : FontWeight.normal,
              color: isSalePrice ? Colors.green : Colors.black87,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
    );
  }
}
