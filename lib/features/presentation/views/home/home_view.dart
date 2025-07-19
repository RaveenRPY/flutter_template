import 'package:AventaPOS/utils/app_colors.dart';
import 'package:AventaPOS/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../bloc/base_bloc.dart';
import '../../bloc/sale/sale_bloc.dart';
import '../../bloc/sale/sale_event.dart';
import '../../bloc/sale/sale_state.dart';
import '../../widgets/vertical_navigation_bar.dart' hide NavigationItem;
import '../new_sale/new_sales_tab.dart';
import '../new_sale/tabs/customers_tab.dart';
import '../new_sale/tabs/products_tab.dart';
import '../new_sale/tabs/reports_tab.dart';
import '../base_view.dart';
import '../../models/navigation_item.dart';

class SaleView extends BaseView {
  const SaleView({super.key});

  @override
  State<SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends BaseViewState<SaleView> {
  late final SaleBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = inject<SaleBloc>();
    _bloc.add(SaleInitializedEvent());
  }

  @override
  Widget buildView(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
      bloc: _bloc,
      builder: (context, state) {
        int selectedTab = 0;
        List<NavigationItem> navItems = [
          NavigationItem(icon: HugeIcons.strokeRoundedShoppingCartCheckIn02,),
          NavigationItem(icon: HugeIcons.strokeRoundedReturnRequest,),
          NavigationItem(icon: HugeIcons.strokeRoundedChartLineData01,),
          NavigationItem(icon: HugeIcons.strokeRoundedChartHistogram,),
          NavigationItem(icon: HugeIcons.strokeRoundedUserGroup,),
        ];

        if (state is SaleLoadedState) {
          selectedTab = state.selectedTabIndex;
        }

        return Row(
          children: [
            VerticalNavigationBar(
              selectedIndex: selectedTab,
              onItemSelected: (index) {
                _bloc.add(SaleTabChangedEvent(index));
              },
              items: navItems,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColors.primaryColor),
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 15, 15, 15),
                  decoration: BoxDecoration(
                      color: AppColors.bgColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: _buildTabContent(selectedTab),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const NewSalesTab();
      case 1:
        return const ProductsTab();
      case 2:
        return const CustomersTab();
      case 3:
        return const ReportsTab();
      default:
        return const Center(child: Text('Unknown Tab'));
    }
  }

  @override
  List<BaseBloc> getBlocs() => [_bloc];
}
