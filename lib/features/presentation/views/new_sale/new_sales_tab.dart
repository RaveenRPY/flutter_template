import 'dart:developer';

import 'package:AventaPOS/features/domain/entities/data.dart';
import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/widgets/app_dropdown.dart';
import 'package:AventaPOS/utils/app_images.dart';
import 'package:AventaPOS/utils/app_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_stylings.dart';
import '../../bloc/sale/sale_bloc.dart';
import '../../bloc/sale/sale_event.dart';
import '../../bloc/sale/sale_state.dart';
import '../../widgets/app_main_button.dart';

class NewSalesTab extends BaseView {
  const NewSalesTab({super.key});

  @override
  State<NewSalesTab> createState() => _NewSalesTabState();
}

class _NewSalesTabState extends BaseViewState<NewSalesTab> {
  final SaleBloc _bloc = inject<SaleBloc>();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final DataGridController _tableController = DataGridController();

  bool _isRetail = true;

  // Add a state variable for filter toggle
  bool _filtersEnabled = false;

  // Add a list of all products and a filtered list
  final List<Product> _allProducts = [
    Product(
        name: 'Abiman takkali 2.5g',
        code: 'at25',
        labelPrice: 1800.00,
        qty: 13,
        salePrice: 1520.00),
    Product(
        name: 'Red Apple Large',
        code: 'ra01',
        labelPrice: 1200.00,
        qty: 20,
        salePrice: 1100.00),
    Product(
        name: 'Green Grapes',
        code: 'gg02',
        labelPrice: 900.00,
        qty: 15,
        salePrice: 850.00),
    Product(
        name: 'Banana Premium',
        code: 'bp03',
        labelPrice: 600.00,
        qty: 30,
        salePrice: 550.00),
    Product(
        name: 'Orange Valencia',
        code: 'ov04',
        labelPrice: 1000.00,
        qty: 10,
        salePrice: 950.00),
    Product(
        name: 'Mango Alphonso',
        code: 'ma05',
        labelPrice: 2000.00,
        qty: 8,
        salePrice: 1800.00),
    Product(
        name: 'Pineapple Queen',
        code: 'pq06',
        labelPrice: 1500.00,
        qty: 12,
        salePrice: 1400.00),
    Product(
        name: 'Watermelon Large',
        code: 'wl07',
        labelPrice: 800.00,
        qty: 18,
        salePrice: 750.00),
  ];
  List<Product> _filteredProducts = [];

  void _toggleState() {
    setState(() {
      _isRetail = !_isRetail;
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc.add(SaleInitializedEvent());
    _focusNode.addListener(() {
      setState(() {});
    });
    _filteredProducts = List.from(_allProducts);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.code.toLowerCase().contains(query);
        }).toList();
      }
    });
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
    return BlocBuilder<SaleBloc, SaleState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is SaleLoadedState) {
          return _buildSalesContent(context, state);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildSalesContent(BuildContext context, SaleLoadedState state) {
    final String buttonText = _isRetail ? 'Retail' : 'Wholesale';
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: buttonText, style: AppStyling.medium14White),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double textWidth = textPainter.width;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 350,
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
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Icon(
                            HugeIcons.strokeRoundedSearch01,
                            size: 20,
                            color: AppColors.darkGrey.withOpacity(0.7),
                          ),
                        ),
                        hintText: "Search here for product",
                        hintStyle: AppStyling.regular12Grey.copyWith(
                            color: AppColors.darkGrey.withOpacity(0.5)),
                      ),
                      style: AppStyling.medium16Black,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      width: textWidth + 60,
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style: AppStyling.medium12White,
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
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedPrinter,
                              size: 20,
                              color: AppColors.darkBlue,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Last Sale',
                              style: AppStyling.medium12Black,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedAddCircle,
                              color: AppColors.darkBlue,
                              size: 20,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'New Tab',
                              style: AppStyling.medium12Black,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Center(
                          child: Icon(
                            HugeIcons.strokeRoundedArrowUpDown,
                            size: 20,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  // Match padding
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 33,
                        height: 33,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(AppImages.userAvatar)),
                      ),
                      1.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Jason Derulo',
                            style: AppStyling.medium14Black.copyWith(height: 1),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Cashier',
                            style: AppStyling.regular10Grey.copyWith(height: 1),
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
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Products Grid
          Expanded(
            child: Row(
              children: [
                // Products Section
                Expanded(
                  flex: 2,
                  child: _searchController.text.isNotEmpty
                      ? _productSection()
                      : _suggestionSection(),
                ),

                const SizedBox(width: 10),

                // Cart Section
                Expanded(
                  flex: 1,
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
    return [_bloc];
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
                      style: AppStyling.semi16Black,
                    ),
                  ],
                ),
                Expanded(
                  child: SfDataGrid(
                    // allowSorting: true,
                    allowColumnsResizing: true,
                    // allowColumnsDragging: true,
                    // frozenRowsCount: 2,
                    // sortIconColor: AppColors.primaryColor,
                    source: ProductDataSource([
                      Product(
                          name: 'Abiman takkali sdsd sdsd sds dfdf 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                      Product(
                          name: 'Abiman takkali 2.5g',
                          code: 'at25',
                          labelPrice: 1800.00,
                          qty: 13,
                          salePrice: 1520.00),
                    ]),
                    columns: [
                      GridColumn(
                        columnName: 'name',
                        width: 300,
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
                        columnName: 'salePrice',
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
                          child: Text('Sale Price',
                              style: AppStyling.regular12Grey),
                        ),
                      ),
                    ],
                    // headerRowHeight: 50,
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
                      style: AppStyling.semi16Black,
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
                                          "Rs. 13,345.00",
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
      padding: EdgeInsets.fromLTRB(16, 20, 10, 20),
      decoration: BoxDecoration(
          color: AppColors.whiteColor, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Products',
                style: AppStyling.semi16Black,
              ),
              Spacer(),
              // Fine-tuned modern filter toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _filtersEnabled = !_filtersEnabled;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  width: 70,
                  height: 36,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: _filtersEnabled
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.98),
                              AppColors.primaryColor.withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !_filtersEnabled
                        ? AppColors.lightGrey.withOpacity(0.8)
                        : null,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: _filtersEnabled
                            ? AppColors.primaryColor.withOpacity(0.13)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: _filtersEnabled
                          ? AppColors.primaryColor
                          : AppColors.darkGrey.withOpacity(0.10),
                      width: 1.1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Label
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        left: _filtersEnabled ? 18 : 40,
                        right: _filtersEnabled ? 48 : 18,
                        top: 0,
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: 1,
                            child: Text(
                              '|',
                              style: AppStyling.regular12Black.copyWith(
                                color: _filtersEnabled
                                    ? Colors.white
                                    : AppColors.darkGrey,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Knob
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        alignment: _filtersEnabled
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: _filtersEnabled
                                  ? AppColors.primaryColor.withOpacity(0.5)
                                  : AppColors.lightGrey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.filter_alt_rounded,
                              size: 18,
                              color: _filtersEnabled
                                  ? AppColors.primaryColor
                                  : AppColors.darkGrey.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          // const SizedBox(height: 20),
          Expanded(
            child: SfDataGrid(
              allowSorting: _filtersEnabled,
              allowColumnsResizing: true,
              controller: _tableController,
              // allowColumnsDragging: true,
              // frozenRowsCount: 2,
              // sortIconColor: AppColors.primaryColor,
              source: ProductDataSource(_filteredProducts),
              onCellTap: (details) {
                if (details.rowColumnIndex.rowIndex > 0) {
                  final rowIndex = details.rowColumnIndex.rowIndex - 1;
                  if (rowIndex < _filteredProducts.length) {
                    final product = _filteredProducts[rowIndex];
                    print(
                        'Tapped product: Name: ${product.name}, Code: ${product.code}, Price: ${product.salePrice}');
                  }
                }
              },
              columns: [
                GridColumn(
                  columnName: 'name',
                  width: 300,
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
                    child: Text('Label Price', style: AppStyling.regular12Grey),
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
                  columnName: 'salePrice',
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
                    child: Text('Sale Price', style: AppStyling.regular12Grey),
                  ),
                ),
              ],
              // headerRowHeight: 50,
              rowHeight: 40,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              columnWidthMode: ColumnWidthMode.fill,
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.darkGrey.withOpacity(0.3),
                          width: 1)),
                  child: Icon(
                    HugeIcons.strokeRoundedShoppingCart01,
                    color: AppColors.darkBlue,
                    size: 20,
                  ),
                ),
                1.horizontalSpace,
                Text(
                  'Cart ()',
                  style: AppStyling.semi16Black,
                ),
              ],
            ),
          ),

          Expanded(
            child: false
                ? const Center(
                    child: Text('Cart is empty'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: AppColors.darkGrey.withOpacity(0.1),
                                width: 1.5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Abiman Takkali 125g",
                                  style: AppStyling.medium14Black,
                                ),
                                Text(
                                  "Rs. 12,000.00",
                                  style: AppStyling.regular12Grey,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Rs. 12,000.00",
                                  style: AppStyling.regular12Grey,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {}, icon: Icon(Icons.add, size: 20,))
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Checkout Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: AppStyling.semi16Black,
                    ),
                    Text(
                      '\$${120023.toStringAsFixed(2)}',
                      style: AppStyling.semi16Black,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AppMainButton(
                    title: 'Complete Sale',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        DataGridCell<double>(
            columnName: 'labelPrice', value: product.labelPrice),
        DataGridCell<int>(columnName: 'qty', value: product.qty),
        DataGridCell<double>(columnName: 'salePrice', value: product.salePrice),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    bool isLowQty = row.getCells()[3].value < 10;

    return DataGridRowAdapter(
      // color: Colors.blueGrey[50],
      cells: row.getCells().asMap().entries.map<Widget>((entry) {
        final idx = entry.key;
        final cell = entry.value;
        final isSalePrice = cell.columnName == 'salePrice';
        final isQty = cell.columnName == 'qty';
        final isName = cell.columnName == 'name';

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.transparent, width: 0),
            borderRadius: isName
                ? BorderRadius.only(
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(60))
                : isSalePrice
                    ? BorderRadius.only(
                        topRight: Radius.circular(60),
                        bottomRight: Radius.circular(60))
                    : BorderRadius.zero,
            color: isLowQty
                ? AppColors.red.withOpacity(0.2)
                : AppColors.bgColor.withOpacity(0.65),
          ),
          alignment: idx == 0 ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          margin: EdgeInsets.fromLTRB(0, 2, isSalePrice ? 8 : 0, 2),
          child: Text(
            cell.value is double
                ? (cell.columnName == 'labelPrice' ||
                        cell.columnName == 'salePrice')
                    ? cell.value.toStringAsFixed(2)
                    : cell.value.toString()
                : cell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: idx == 0
                ? AppStyling.medium12Black
                : isSalePrice
                    ? AppStyling.medium12Black.copyWith(color: AppColors.green)
                    : isQty
                        ? AppStyling.semi12Black.copyWith(
                            color: isLowQty
                                ? AppColors.red
                                : CupertinoColors.activeBlue)
                        : AppStyling.medium12Black,
            // style: TextStyle(
            //   fontWeight: idx == 0 ? FontWeight.bold : FontWeight.normal,
            //   color: isSalePrice ? Colors.green : Colors.black87,
            //   fontSize: 16,
            // ),
          ),
        );
      }).toList(),
    );
  }
}
