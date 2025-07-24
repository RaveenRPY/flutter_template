import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:AventaPOS/features/presentation/views/home/widgets/cash_in_out.dart';
import 'package:flutter/widgets.dart';

import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/process_payment_view.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/widgets/cart_item.dart';
import 'package:AventaPOS/features/presentation/widgets/zynolo_toast.dart';
import 'package:AventaPOS/features/presentation/widgets/app_dialog_box.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/app_images.dart';
import 'package:AventaPOS/utils/app_spacing.dart';
import 'package:AventaPOS/utils/enums.dart';
import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_popup.dart' show PopupWindow;
import '../../../../utils/app_stylings.dart';
import '../../bloc/sale/sale_bloc.dart';
import '../../widgets/app_main_button.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

class NewSalesTab extends BaseView {
  const NewSalesTab({super.key});

  @override
  State<NewSalesTab> createState() => _NewSalesTabState();
}

class _NewSalesTabState extends BaseViewState<NewSalesTab> {
  final SaleBloc _salesBloc = inject<SaleBloc>();
  final StockBloc _stockBloc = inject<StockBloc>();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final DataGridController _tableController = DataGridController();

  bool _isRetail = true;
  bool _isCheckOutPage = false;

  bool _filtersEnabled = false;

  bool _isSelectionMode = false;
  final Set<int> _selectedItems = {};

  List<Stock> _cartItems = [];

  List<Stock> _allStocks = AppConstants.stockList ?? [];
  List<Stock> _filteredStocks = [];

  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  final String _ip = '192.168.123.123';
  final String _port = '9100';

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  // Get Printer List
  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
      ConnectionType.NETWORK,
    ]);
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      log(event.map((e) => e.name).toList().toString());
      setState(() {
        printers = event;
        printers.removeWhere(
            (element) => element.name == null || element.name == '');
      });
    });
  }

  void _toggleState() {
    setState(() {
      _isRetail = !_isRetail;
    });
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
    _stockBloc.add(GetStockEvent());
    _focusNode.addListener(() {
      setState(() {});
    });
    _filteredStocks = List.from(_allStocks);
    _searchController.addListener(_onSearchChanged);

    _focusNode.requestFocus();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStocks = List.from(_allStocks);
      } else {
        _filteredStocks = _allStocks.where((stock) {
          return (stock.item?.description?.toLowerCase().contains(query) ??
                  false) ||
              (stock.item?.code?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _deleteSelectedItems() {
    // Create a new list without selected items
    final newCartItems = <Stock>[];

    for (int i = 0; i < _cartItems.length; i++) {
      if (!_selectedItems.contains(i)) {
        newCartItems.add(_cartItems[i]);
      }
    }

    // Update the cart items list and clear selection
    setState(() {
      _cartItems = newCartItems;
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _incrementQuantity(int index) {
    if (index < _cartItems.length) {
      setState(() {
        _cartItems[index] = Stock(
          id: _cartItems[index].id,
          item: _cartItems[index].item,
          labelPrice: _cartItems[index].labelPrice,
          itemCost: _cartItems[index].itemCost,
          retailPrice: _cartItems[index].retailPrice,
          wholesalePrice: _cartItems[index].wholesalePrice,
          retailDiscount: _cartItems[index].retailDiscount,
          wholesaleDiscount: _cartItems[index].wholesaleDiscount,
          qty: _cartItems[index].qty,
          status: _cartItems[index].status,
          statusDescription: _cartItems[index].statusDescription,
          cartQty: (_cartItems[index].cartQty ?? 0) + 1,
        );
      });
    }
  }

  void _showRemoveItemConfirmation(int index, String productName) {
    AppDialogBox.show(
      context,
      title: 'Remove Item',
      message: 'Are you sure you want to remove "$productName" from the cart?',
      image: AppImages.failedDialog,
      negativeButtonText: 'Cancel',
      negativeButtonTap: () {
        // Do nothing, just close the dialog
      },
      positiveButtonText: 'Remove',
      positiveButtonTap: () {
        _removeItemFromCart(index);
      },
    );
  }

  void _removeItemFromCart(int index) {
    if (index < _cartItems.length) {
      final productName = _cartItems[index].item?.description ?? '';
      final newCartItems = <Stock>[];
      for (int i = 0; i < _cartItems.length; i++) {
        if (i != index) {
          newCartItems.add(_cartItems[i]);
        }
      }

      setState(() {
        _cartItems = newCartItems;
      });

      // Show removal toast
      _showRemovedToast(productName);
    }
  }

  void _decrementQuantity(int index) {
    if (index < _cartItems.length) {
      int currentQty = _cartItems[index].cartQty ?? 1;
      if (currentQty > 1) {
        setState(() {
          _cartItems[index] = Stock(
            id: _cartItems[index].id,
            item: _cartItems[index].item,
            labelPrice: _cartItems[index].labelPrice,
            itemCost: _cartItems[index].itemCost,
            retailPrice: _cartItems[index].retailPrice,
            wholesalePrice: _cartItems[index].wholesalePrice,
            retailDiscount: _cartItems[index].retailDiscount,
            wholesaleDiscount: _cartItems[index].wholesaleDiscount,
            qty: _cartItems[index].qty,
            status: _cartItems[index].status,
            statusDescription: _cartItems[index].statusDescription,
            cartQty: currentQty - 1,
          );
        });
      } else {
        // Show confirmation dialog before removing item
        _showRemoveItemConfirmation(
            index, _cartItems[index].item?.description ?? '');
      }
    }
  }

  double _calculateTotalPrice(int index) {
    if (index < _cartItems.length) {
      return (_cartItems[index].retailPrice ?? 0) *
          (_cartItems[index].cartQty ?? 0);
    }
    return 0.0;
  }

  double _calculateCartTotal() {
    return _cartItems.fold(0.0, (total, item) {
      return total + ((item.retailPrice ?? 0) * (item.cartQty ?? 0));
    });
  }

  bool _isProductInCart(String productCode, double labelPrice) {
    return _cartItems.any((item) {
      log(item.item!.code.toString());
      return (item.item?.code == productCode) &&
          (item.labelPrice == labelPrice);
    });
  }

  void _showDuplicateItemToast() {
    ZynoloToast(
      title: 'Item already in cart!',
      toastType: Toast.warning,
      animationDuration: Duration(milliseconds: 500),
      toastPosition: Position.top,
      animationType: AnimationType.fromTop,
      backgroundColor: AppColors.whiteColor.withOpacity(1),
    ).show(context);
  }

  void _showSuccessToast(String productName) {
    ZynoloToast(
      title: '$productName added to cart!',
      toastType: Toast.success,
      animationDuration: Duration(milliseconds: 500),
      toastPosition: Position.top,
      animationType: AnimationType.fromTop,
      backgroundColor: AppColors.whiteColor.withOpacity(1),
    ).show(context);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);
  }

  void _showRemovedToast(String productName) {
    ZynoloToast(
      title: '$productName removed from cart!',
      toastType: Toast.failed,
      animationDuration: Duration(milliseconds: 500),
      toastPosition: Position.top,
      animationType: AnimationType.fromTop,
      backgroundColor: AppColors.whiteColor.withOpacity(1),
    ).show(context);
  }

  void addProductToCart(Stock stock, int quantity, double price) {
    // Check if item already exists in cart (by code and label price)
    final index = _cartItems.indexWhere((item) =>
        item.item?.code == stock.item?.code &&
        item.labelPrice == stock.labelPrice);
    final cartStock = Stock(
      id: stock.id,
      item: stock.item,
      labelPrice: stock.labelPrice,
      itemCost: stock.itemCost,
      retailPrice: price,
      wholesalePrice: stock.wholesalePrice,
      retailDiscount: stock.retailDiscount,
      wholesaleDiscount: stock.wholesaleDiscount,
      qty: stock.qty,
      status: stock.status,
      statusDescription: stock.statusDescription,
      cartQty: quantity, // Store entered cart quantity
    );
    setState(() {
      if (index != -1) {
        _cartItems[index] = cartStock;
      } else {
        _cartItems.add(cartStock);
      }
    });
    log((cartStock.cartQty ?? 0).toString());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget buildView(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StockBloc>(create: (context) => _stockBloc),
        BlocProvider<SaleBloc>(create: (context) => _salesBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<StockBloc, BaseState<StockState>>(
              listener: (context, state) {
            if (state is GetStockSuccessState) {
              setState(() {
                AppConstants.stockList = state.stockList;
                _allStocks = _filteredStocks = state.stockList ?? [];
              });
            } else if (state is GetStockFailedState) {
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
          }),
        ],
        child: !_isCheckOutPage
            ? _buildSalesContent(context)
            : ProcessPaymentView(
                params: PaymentParams(
                    cartItemList: _cartItems,
                    total: _calculateCartTotal(),
                    isRetail: _isRetail,
                    onPop: (bool? isNew) {
                      setState(() {
                        _isCheckOutPage = false;
                        if (isNew ?? false) {
                          _cartItems.clear();
                          _searchController.clear();
                        }
                      });
                    })),
      ),
    );
  }

  Widget _buildSalesContent(BuildContext context) {
    final String buttonText = _isRetail ? 'Retail' : 'Wholesale';
    final double textWidth = buttonText.length * 8.0;

    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 20.w,
                  child: Form(
                    key: _searchKey,
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        fillColor: AppColors.whiteColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(color: AppColors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(color: AppColors.transparent),
                        ),
                        // Adjusted padding
                        prefixIcon: Icon(
                          HugeIcons.strokeRoundedSearch01,
                          size: 13.sp,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        hintText: "Search here for product",
                        isDense: true,
                        hintStyle: AppStyling.regular12Grey.copyWith(
                            color: AppColors.darkGrey.withOpacity(0.5),
                            height: 1,
                            fontSize: 10.sp),
                        // contentPadding: EdgeInsets.zero
                      ),
                      style: AppStyling.medium14Black,
                      onChanged: (value) {
                        log(_searchController.text);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                0.5.horizontalSpace,
                Material(
                  color: buttonText == 'Retail'
                      ? AppColors.primaryColor
                      : AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(60),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(60),
                    splashColor: buttonText == 'Retail'
                        ? AppColors.darkBlue.withOpacity(0.4)
                        : AppColors.primaryColor.withOpacity(0.4),
                    highlightColor: buttonText == 'Retail'
                        ? AppColors.darkBlue.withOpacity(0.4)
                        : AppColors.primaryColor.withOpacity(0.4),
                    onTap: _toggleState,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.sp, vertical: 0),
                      width: textWidth + 20.sp,
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style:
                            AppStyling.regular12White.copyWith(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                0.5.horizontalSpace,
                Material(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(60),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(60),
                    splashColor: AppColors.darkBlue.withOpacity(0.1),
                    highlightColor: AppColors.darkBlue.withOpacity(0.1),
                    onTap: () {
                      _stockBloc.add(GetStockEvent());
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 13.sp, vertical: 0),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedRefresh,
                              size: 13.sp,
                              color: AppColors.darkBlue,
                            ),
                            SizedBox(
                              width: 8.sp,
                            ),
                            Text(
                              'Refresh',
                              style: AppStyling.regular14Black
                                  .copyWith(fontSize: 11.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                0.5.horizontalSpace,
                Material(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(60),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(60),
                    splashColor: AppColors.darkBlue.withOpacity(0.1),
                    highlightColor: AppColors.darkBlue.withOpacity(0.1),
                    onTap: () {},
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 13.sp, vertical: 0),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedAddCircle,
                              color: AppColors.darkBlue,
                              size: 13.sp,
                            ),
                            SizedBox(
                              width: 8.sp,
                            ),
                            Text(
                              'New Tab',
                              style: AppStyling.regular12Black
                                  .copyWith(fontSize: 11.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                0.5.horizontalSpace,
                Material(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(60),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(60),
                    splashColor: AppColors.darkBlue.withOpacity(0.1),
                    highlightColor: AppColors.darkBlue.withOpacity(0.1),
                    onTap: () {
                      CashInOutWindow.show(context);
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Icon(
                          HugeIcons.strokeRoundedArrowUpDown,
                          size: 13.sp,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.fromLTRB(10.sp, 5.sp, 10.sp, 5.sp),
                  // Match padding
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(AppImages.userAvatar)),
                      ),
                      SizedBox(
                        width: 8.sp,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.username ?? "User",
                            style:
                                AppStyling.regular14Black.copyWith(height: 1),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Cashier',
                            style: AppStyling.regular10Grey
                                .copyWith(height: 1, fontSize: 10.sp),
                          ),
                        ],
                      ),
                      1.5.horizontalSpace,
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.bgColor),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.darkBlue,
                          size: 13.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.sp),
          // Products Grid
          Expanded(
            child: Row(
              children: [
                // Products Section
                Expanded(
                  flex: 5,
                  child: true ? _productSection() : _suggestionSection(),
                ),

                SizedBox(width: 10.sp),

                // Cart Section
                Expanded(
                  flex: 3,
                  child: _cartSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_salesBloc, _stockBloc];
  }

  Widget _suggestionSection() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 20, 10, 20),
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Products',
                      style: AppStyling.medium20Black,
                    ),
                  ],
                ),
                Expanded(
                  child: SfDataGrid(
                    allowColumnsResizing: true,
                    source: StockDataSource(_filteredStocks, _isRetail),
                    onCellTap: (details) {
                      if (details.rowColumnIndex.rowIndex > 0) {
                        final rowIndex = details.rowColumnIndex.rowIndex - 1;
                        if (rowIndex < _filteredStocks.length) {
                          final stock = _filteredStocks[rowIndex];
                          if (_isProductInCart(
                              stock.item?.code ?? '', stock.labelPrice ?? 0)) {
                            _showDuplicateItemToast();
                          } else {
                            PopupWindow.show(
                              context,
                              itemCode: stock.item?.code,
                              itemName: stock.item?.description,
                              labelPrice: stock.labelPrice,
                              salePrice: stock.retailPrice,
                              stockQty: stock.qty,
                              onAddToCart: (Stock s, int qty, double price) {
                                addProductToCart(s, qty, price);
                              },
                            );
                          }
                        }
                      }
                    },
                    columns: [
                      GridColumn(
                        columnName: 'name',
                        width: 300,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Text(
                            'Item Name',
                            style: AppStyling.regular12Grey,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'code',
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Text('Code', style: AppStyling.regular12Grey),
                        ),
                      ),
                      GridColumn(
                        columnName: 'labelPrice',
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Text('Label Price',
                              style: AppStyling.regular12Grey),
                        ),
                      ),
                      GridColumn(
                        columnName: 'qty',
                        width: 80,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Text('QTY', style: AppStyling.regular12Grey),
                        ),
                      ),
                      GridColumn(
                        columnName: 'retailPrice',
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Text('Retail Price',
                              style: AppStyling.regular12Grey),
                        ),
                      ),
                    ],
                    rowHeight: 40,
                    gridLinesVisibility: GridLinesVisibility.horizontal,
                    headerGridLinesVisibility: GridLinesVisibility.horizontal,
                    columnWidthMode: ColumnWidthMode.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 20, 10, 20),
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest Sales',
                      style: AppStyling.medium20Black,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          overlayColor: WidgetStatePropertyAll(
                        AppColors.darkGrey.withOpacity(0.2),
                      )),
                      child: Text(
                        "Show All",
                        style: AppStyling.regular10Black
                            .copyWith(color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          width: double.infinity,
                          // height: 100,
                          margin: EdgeInsets.only(bottom: 5),
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: AppColors.bgColor.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(AppImages.userAvatar),
                                ),
                              ),
                              1.3.horizontalSpace,
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Emma Watson",
                                          style: AppStyling.medium12Black,
                                        ),
                                        Text(
                                          "#12345",
                                          style: AppStyling.regular10Black,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Items",
                                          style: AppStyling.regular10Black,
                                        ),
                                        Text(
                                          "13",
                                          style: AppStyling.semi12Black,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Amount",
                                          style: AppStyling.regular10Black,
                                        ),
                                        Text(
                                          _formatCurrency(13345.00),
                                          style: AppStyling.semi12Black,
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      color: AppColors.primaryColor
                                          .withOpacity(0.3),
                                      splashColor: AppColors.primaryColor
                                          .withOpacity(0.3),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                        AppColors.primaryColor.withOpacity(0.1),
                                      )),
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 20,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _productSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.sp, 14.sp, 10.sp, 14.sp),
      decoration: BoxDecoration(
          color: AppColors.whiteColor, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Products',
                style: AppStyling.medium16Black,
              ),
              // Spacer(),
              // // Fine-tuned modern filter toggle button
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       _filtersEnabled = !_filtersEnabled;
              //     });
              //   },
              //   child: AnimatedContainer(
              //     duration: const Duration(milliseconds: 320),
              //     curve: Curves.easeInOutCubic,
              //     width: 70,
              //     height: 36,
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              //     decoration: BoxDecoration(
              //       gradient: _filtersEnabled
              //           ? LinearGradient(
              //               colors: [
              //                 AppColors.primaryColor.withOpacity(0.98),
              //                 AppColors.primaryColor.withOpacity(0.85),
              //               ],
              //               begin: Alignment.topLeft,
              //               end: Alignment.bottomRight,
              //             )
              //           : null,
              //       color: !_filtersEnabled
              //           ? AppColors.lightGrey.withOpacity(0.8)
              //           : null,
              //       borderRadius: BorderRadius.circular(32),
              //       boxShadow: [
              //         BoxShadow(
              //           color: _filtersEnabled
              //               ? AppColors.primaryColor.withOpacity(0.13)
              //               : Colors.black.withOpacity(0.06),
              //           blurRadius: 8,
              //           offset: Offset(0, 2),
              //         ),
              //       ],
              //       border: Border.all(
              //         color: _filtersEnabled
              //             ? AppColors.primaryColor
              //             : AppColors.darkGrey.withOpacity(0.10),
              //         width: 1.1,
              //       ),
              //     ),
              //     child: Stack(
              //       alignment: Alignment.centerLeft,
              //       children: [
              //         // Label
              //         AnimatedPositioned(
              //           duration: const Duration(milliseconds: 320),
              //           left: _filtersEnabled ? 18 : 40,
              //           right: _filtersEnabled ? 48 : 18,
              //           top: 0,
              //           bottom: 0,
              //           child: Align(
              //             alignment: Alignment.center,
              //             child: AnimatedOpacity(
              //               duration: const Duration(milliseconds: 200),
              //               opacity: 1,
              //               child: Text(
              //                 '|',
              //                 style: AppStyling.regular12Black.copyWith(
              //                   color: _filtersEnabled
              //                       ? Colors.white
              //                       : AppColors.darkGrey,
              //                   fontWeight: FontWeight.w800,
              //                   letterSpacing: 0.2,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //         // Knob
              //         AnimatedAlign(
              //           duration: const Duration(milliseconds: 320),
              //           curve: Curves.easeInOutCubic,
              //           alignment: _filtersEnabled
              //               ? Alignment.centerRight
              //               : Alignment.centerLeft,
              //           child: Container(
              //             width: 28,
              //             height: 28,
              //             decoration: BoxDecoration(
              //               color: Colors.white,
              //               shape: BoxShape.circle,
              //               boxShadow: [
              //                 BoxShadow(
              //                   color: Colors.black.withOpacity(0.09),
              //                   blurRadius: 6,
              //                   offset: Offset(0, 2),
              //                 ),
              //               ],
              //               border: Border.all(
              //                 color: _filtersEnabled
              //                     ? AppColors.primaryColor.withOpacity(0.5)
              //                     : AppColors.lightGrey,
              //                 width: 1.0,
              //               ),
              //             ),
              //             child: Center(
              //               child: Icon(
              //                 Icons.filter_alt_rounded,
              //                 size: 18,
              //                 color: _filtersEnabled
              //                     ? AppColors.primaryColor
              //                     : AppColors.darkGrey.withOpacity(0.7),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   width: 10,
              // ),
            ],
          ),
          // const SizedBox(height: 20),
          Expanded(
            child: _filteredStocks.isNotEmpty
                ? SfDataGrid(
                    allowSorting: _filtersEnabled,
                    allowColumnsResizing: true,
                    controller: _tableController,
                    source: StockDataSource(_filteredStocks, _isRetail),
                    onCellTap: (details) {
                      if (details.rowColumnIndex.rowIndex > 0) {
                        final rowIndex = details.rowColumnIndex.rowIndex - 1;
                        if (rowIndex < _filteredStocks.length) {
                          final stock = _filteredStocks[rowIndex];
                          if (_isProductInCart(
                              stock.item?.code ?? '', stock.labelPrice ?? 0)) {
                            _showDuplicateItemToast();
                          } else {
                            PopupWindow.show(
                              context,
                              stock: stock,
                              itemCode: stock.item?.code,
                              itemName: stock.item?.description,
                              labelPrice: stock.labelPrice,
                              salePrice: _isRetail ? stock.retailPrice : stock.wholesalePrice,
                              stockQty: stock.qty,
                              cost: stock.itemCost,
                              onAddToCart: addProductToCart,
                            );
                          }
                        }
                      }
                    },
                    columns: [
                      GridColumn(
                        columnName: 'name',
                        width: 17.w,

                        // Set a wider width for item names
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.sp, vertical: 0.sp),
                          child: Text(
                            'Item Name',
                            style: AppStyling.regular12Grey
                                .copyWith(fontSize: 11.sp),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'code',
                        // width: 11.w,
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        autoFitPadding: EdgeInsets.zero,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Code',
                            style: AppStyling.regular12Grey
                                .copyWith(fontSize: 11.sp),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'labelPrice',
                        // columnWidthMode: ColumnWidthMode.fitByCellValue,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.sp, vertical: 0.sp),
                          child: Text(
                            'Label Price',
                            style: AppStyling.regular12Grey
                                .copyWith(fontSize: 11.sp),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'qty',
                        width: 8.w,
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.sp, vertical: 0.sp),
                          child: Text(
                            'QTY',
                            style: AppStyling.regular12Grey
                                .copyWith(fontSize: 11.sp),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'salePrice',
                        // width: 10.w,
                        // columnWidthMode: ColumnWidthMode.fitByCellValue,
                        label: Container(
                          decoration: BoxDecoration(
                            color: AppColors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                             right: 5.sp),
                          child: Text(
                            _isRetail ? 'Sale Price' : 'Wholesale Price',
                            textAlign: TextAlign.center,
                            style: AppStyling.regular12Grey
                                .copyWith(fontSize: 11.sp),
                          ),
                        ),
                      ),
                    ],
                    // headerRowHeight: 50,
                    rowHeight: 4.h,
                    gridLinesVisibility: GridLinesVisibility.horizontal,
                    headerGridLinesVisibility: GridLinesVisibility.horizontal,
                    columnWidthMode: ColumnWidthMode.fill,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedFileEmpty01,
                          size: 100,
                          color: AppColors.darkGrey.withOpacity(0.3),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No any Items',
                          style: AppStyling.medium16Black.copyWith(
                            color: AppColors.darkGrey.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add products to your shop',
                          style: AppStyling.regular14Grey.copyWith(
                            color: AppColors.darkGrey.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cartSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.sp, 14.sp, 10.sp, 12.sp),
            child: Row(
              children: [
                // Container(
                //   padding: EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //       color: AppColors.transparent,
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(
                //           color: AppColors.darkGrey.withOpacity(0.3),
                //           width: 1)),
                //   child: Icon(
                //     HugeIcons.strokeRoundedShoppingCart01,
                //     color: AppColors.darkBlue,
                //     size: 20,
                //   ),
                // ),
                // 1.horizontalSpace,
                Expanded(
                  child: _isSelectionMode
                      ? Text(
                          'Select Items (${_selectedItems.length})',
                          style: AppStyling.regular16Grey,
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Cart',
                              style: AppStyling.medium16Black,
                            ),
                            SizedBox(width: 7.sp),
                            Text(
                              '(${_cartItems.length})',
                              style: AppStyling.regular16Grey
                                  .copyWith(color: AppColors.darkBlue),
                            ),
                          ],
                        ),
                ),
                if (_isSelectionMode) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedItems.clear();
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: AppStyling.medium12Black
                          .copyWith(color: AppColors.darkGrey, fontSize: 11.sp),
                    ),
                  ),
                  SizedBox(width: 8),
                  if (_selectedItems.isNotEmpty)
                    TextButton(
                      onPressed: _deleteSelectedItems,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.sp, vertical: 5.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: AppStyling.regular14Grey.copyWith(
                            color: AppColors.whiteColor, fontSize: 11.sp),
                      ),
                    ),
                ] else ...[
                  if (_cartItems.isNotEmpty)
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            AppColors.red.withOpacity(0.2)),
                      ),
                      onPressed: () {
                        // _isSelectionMode = true;
                        if (_cartItems.isNotEmpty) {
                          AppDialogBox.show(
                            context,
                            title: 'Clear Cart',
                            message: 'Are you sure you want to clear the cart?',
                            image: AppImages.failedDialog,
                            negativeButtonText: 'No',
                            negativeButtonTap: () {
                              // Do nothing, just close the dialog
                            },
                            positiveButtonText: 'Clear',
                            positiveButtonTap: () {
                              setState(() {
                                _cartItems.clear();
                              });
                            },
                          );
                        }
                      },
                      icon: Icon(
                        HugeIcons.strokeRoundedDelete03,
                        color: AppColors.red,
                        size: 13.sp,
                      ),
                    ),
                ],
              ],
            ),
          ),
          0.verticalSpace,
          Expanded(
            child: false
                ? const Center(
                    child: Text('Cart is empty'),
                  )
                : _cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedShoppingCart01,
                              size: 25.sp,
                              color: AppColors.darkGrey.withOpacity(0.3),
                            ),
                            SizedBox(height: 10.sp),
                            Text(
                              'Cart is empty',
                              style: AppStyling.medium14Black.copyWith(
                                color: AppColors.darkGrey.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 5.sp),
                            Text(
                              'Add products to your cart',
                              style: AppStyling.regular12Grey.copyWith(
                                color: AppColors.darkGrey.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          log((item.cartQty ?? 0).toString());
                          return CartItem(
                            productName: item.item?.description ?? '',
                            productCode: item.item?.code ?? '',
                            unitPrice: item.retailPrice ?? 0,
                            totalPrice: _calculateTotalPrice(index),
                            quantity: item.cartQty ?? 0,
                            isLastItem: index == _cartItems.length - 1,
                            isSelectionMode: _isSelectionMode,
                            isSelected: _selectedItems.contains(index),
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  if (_selectedItems.contains(index)) {
                                    _selectedItems.remove(index);
                                  } else {
                                    _selectedItems.add(index);
                                  }
                                });
                              } else {
                                PopupWindow.show(context,
                                    stock: item,
                                    itemCode: item.item?.code,
                                    itemName: item.item?.description,
                                    labelPrice: item.labelPrice,
                                    salePrice: item.retailPrice,
                                    qty: item.cartQty,
                                    stockQty: item.qty,
                                    cost: item.itemCost,
                                    onAddToCart: addProductToCart,
                                    isForEdit: true);
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                setState(() {
                                  _isSelectionMode = true;
                                  _selectedItems.add(index);
                                });
                              }
                            },
                            onIncrement: _isSelectionMode
                                ? null
                                : () {
                                    _incrementQuantity(index);
                                  },
                            onDecrement: _isSelectionMode
                                ? null
                                : () {
                                    _decrementQuantity(index);
                                  },
                          );
                        },
                      ),
          ),

          // Checkout Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  // height: 400,
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.sp, vertical: 12.sp),
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub Total',
                          style: AppStyling.medium12Black
                              .copyWith(fontSize: 11.sp),
                        ),
                        Text(
                          _formatCurrency(_calculateCartTotal()),
                          style: AppStyling.semi14Black,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 7.sp),
                Row(
                  children: [
                    Expanded(
                      child: AppMainButton(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 3.sp),
                          child: Icon(
                            HugeIcons.strokeRoundedUserAdd01,
                            color: AppColors.darkBlue,
                            size: 13.sp,
                          ),
                        ),
                        color: AppColors.primaryColor.withOpacity(0.2),
                        title: 'Customer',
                        titleStyle: AppStyling.medium12Black.copyWith(
                            color: AppColors.darkBlue, fontSize: 11.sp),
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 7.sp),
                    Expanded(
                      child: AppMainButton(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 3.sp),
                          child: Icon(
                            HugeIcons.strokeRoundedCancelCircle,
                            color: AppColors.red,
                            size: 13.sp,
                          ),
                        ),
                        color: AppColors.red.withOpacity(0.15),
                        title: 'Cancel Sale',
                        titleStyle: AppStyling.medium12Black
                            .copyWith(color: AppColors.red, fontSize: 11.sp),
                        onTap: () {
                          AppDialogBox.show(
                            context,
                            title: 'Cancel Sale',
                            message:
                                'Are you sure you want to cancel the sale ?',
                            image: AppImages.failedDialog,
                            negativeButtonText: 'No',
                            negativeButtonTap: () {
                              // Do nothing, just close the dialog
                            },
                            positiveButtonText: 'Yes',
                            positiveButtonTap: () {
                              setState(() {
                                _cartItems.clear();
                                _searchController.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
                AppMainButton(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 4.sp),
                    child: Icon(HugeIcons.strokeRoundedCheckmarkBadge03),
                  ),
                  title: 'Checkout',
                  titleStyle: AppStyling.medium12Black
                      .copyWith(color: AppColors.whiteColor, fontSize: 11.sp),
                  onTap: () async {
                    // final service = FlutterThermalPrinterNetwork(_ip,
                    //     port: int.parse(_port));
                    // await service.connect();
                    // final bytes = await _generateReceipt();
                    // await service.printTicket(bytes);
                    // await service.disconnect();
                    if (_cartItems.isNotEmpty) {
                      setState(() {
                        _isCheckOutPage = true;
                      });
                    } else {
                      ZynoloToast(
                        title: 'Your shopping cart is empty !',
                        toastType: Toast.warning,
                        animationDuration: Duration(milliseconds: 500),
                        toastPosition: Position.top,
                        animationType: AnimationType.fromTop,
                        backgroundColor: AppColors.whiteColor.withOpacity(1),
                      ).show(context);
                    }
                  },
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final service = FlutterThermalPrinterNetwork(
                //       _ip,
                //       port: int.parse(_port),
                //     );
                //     await service.connect();
                //     final profile = await CapabilityProfile.load();
                //     final generator = Generator(PaperSize.mm80, profile);
                //     List<int> bytes = [];
                //     if (context.mounted) {
                //       bytes =
                //           await FlutterThermalPrinter.instance.screenShotWidget(
                //         context,
                //         generator: generator,
                //         widget: receiptWidget("Network"),
                //       );
                //       bytes += generator.cut();
                //       await service.printTicket(bytes);
                //     }
                //     await service.disconnect();
                //   },
                //   child: const Text('Test USB printer'),
                // ),

                // const SizedBox(height: 12),
                // ListView.builder(
                //   itemCount: printers.length,
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       onTap: () async {
                //         if (printers[index].isConnected ?? false) {
                //           await _flutterThermalPrinterPlugin
                //               .disconnect(printers[index]);
                //         } else {
                //           await _flutterThermalPrinterPlugin
                //               .connect(printers[index]);
                //         }
                //       },
                //       title: Text(printers[index].name ?? 'No Name'),
                //       subtitle:
                //           Text("Connected: ${printers[index].isConnected}"),
                //       trailing: IconButton(
                //         icon: const Icon(Icons.connect_without_contact),
                //         onPressed: () async {
                //           await _flutterThermalPrinterPlugin.printWidget(
                //             context,
                //             printer: printers[index],
                //             printOnBle: true,
                //             widget: receiptWidget(
                //               printers[index].connectionTypeString,
                //             ),
                //           );
                //         },
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StockDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  StockDataSource(List<Stock> stocks, bool isRetail) {
    _rows = stocks.map<DataGridRow>((stock) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'name', value: stock.item?.description ?? ''),
        DataGridCell<String>(columnName: 'code', value: stock.item?.code ?? ''),
        DataGridCell<double>(
            columnName: 'labelPrice', value: stock.labelPrice ?? 0),
        DataGridCell<int>(columnName: 'qty', value: stock.qty ?? 0),
        DataGridCell<double>(
            columnName: 'retailPrice',
            value: isRetail ? stock.retailPrice : stock.wholesalePrice),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    bool isLowQty = row.getCells()[3].value < 10;

    return DataGridRowAdapter(
      cells: row.getCells().asMap().entries.map<Widget>((entry) {
        final idx = entry.key;
        final cell = entry.value;
        final isRetailPrice = cell.columnName == 'retailPrice';
        final isQty = cell.columnName == 'qty';
        final isName = cell.columnName == 'name';

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.transparent, width: 0),
            borderRadius: isName
                ? BorderRadius.only(
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(60))
                : isRetailPrice
                    ? BorderRadius.only(
                        topRight: Radius.circular(60),
                        bottomRight: Radius.circular(60))
                    : BorderRadius.zero,
            color: isLowQty
                ? AppColors.red.withOpacity(0.15)
                : AppColors.bgColor.withOpacity(0.65),
          ),
          alignment: idx == 0 ? Alignment.centerLeft : Alignment.center,
          padding:  EdgeInsets.only(left: idx == 0 ? 13.sp:0),
          margin: EdgeInsets.fromLTRB(0, 0, isRetailPrice ? 8 : 0, 3),
          child: Text(
            cell.value is double
                ? (cell.columnName == 'labelPrice' ||
                        cell.columnName == 'retailPrice')
                    ? NumberFormat.currency(
                        locale: 'en_US',
                        symbol: '',
                        decimalDigits: 2,
                      ).format(cell.value)
                    : cell.value.toString()
                : cell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: idx == 0
                ? AppStyling.medium12Black.copyWith(fontSize: 11.sp)
                : isRetailPrice
                    ? AppStyling.medium12Black
                        .copyWith(color: Color(0xff1a932f), fontSize: 11.sp)
                    : isQty
                        ? AppStyling.semi12Black.copyWith(
                            color: isLowQty
                                ? AppColors.red
                                : CupertinoColors.activeBlue,
                            fontSize: 11.sp)
                        : AppStyling.medium12Black.copyWith(fontSize: 11.sp),
          ),
        );
      }).toList(),
    );
  }
}

Future<List<int>> _generateReceipt() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  const invoiceNo = "TRI1234";
  const date = "2025-07-19 10:32 AM";
  const from = "Location A";
  const to = "Location B";

  final items = [
    {"name": "Abiman Takkali 25g", "code": "abt125", "qty": 10, "unit": "Pack"},
    {"name": "Abiman Takkali 25g", "code": "abt125", "qty": 5, "unit": "Pack"},
    {"name": "Abiman Takkali 25g", "code": "abt125", "qty": 2, "unit": "Pack"},
  ];

  int total = 0;

  // Open cash drawer
  bytes += generator.drawer();

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

  bytes += generator.text(
    'ITEM TRANSFER INVOICE',
    styles: PosStyles(align: PosAlign.center, bold: true),
  );

  bytes += generator.hr();

  // Invoice metadata
  bytes += generator.text('Date       : $date');
  bytes += generator.text('Invoice No : $invoiceNo');
  bytes += generator.text('From       : $from');
  bytes += generator.text('To         : $to');

  bytes += generator.hr();

  // Table header
  bytes += generator.text(
    'No  Item Name              Code     Qty  Unit',
    styles: PosStyles(bold: true),
  );

  bytes += generator.hr();

  // Items
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    total += item["qty"] as int;

    final line = '${(i + 1).toString().padRight(4)}'
        '${(item["name"] as String).padRight(22)}'
        '${(item["code"] as String).padRight(8)}'
        '${item["qty"].toString().padRight(8)}'
        '${item["unit"]}';

    bytes += generator.text(line);
  }

  // Total
  bytes += generator.hr();
  bytes += generator.text(
    'TOTAL ITEMS    :   $total',
    styles: PosStyles(bold: true),
  );
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
  bytes += generator.text('Sent By     : _________________________________');
  bytes += generator.text('Received By : _________________________________');
  bytes += generator.text('Date        : _________________________________');
  bytes += generator.text('');
  bytes += generator.hr();

  // Footer
  bytes += generator.text(
    'Thank You !',
    styles: PosStyles(align: PosAlign.center, bold: true),
  );

  bytes += generator.hr();

  // Barcode
  // bytes +=  generator.barcode(Barcode.code39(invoiceNo));

  // Powered by
  bytes += generator.text(
    'Powered By AventaPOS',
    styles: PosStyles(align: PosAlign.center),
  );

  bytes += generator.feed(2);
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
