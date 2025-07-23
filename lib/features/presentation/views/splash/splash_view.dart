import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/sale/sale_bloc.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/utils/app_colors.dart';
import 'package:AventaPOS/utils/app_spacing.dart';
import 'package:AventaPOS/utils/app_stylings.dart';
import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/material.dart';

class SplashView extends BaseView {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends BaseViewState<SplashView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, Routes.kLoginView);
    });
  }

  final _bloc = SaleBloc();

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "AVENTA",
                  style: AppStyling.semi35Black
                      .copyWith(color: AppColors.whiteColor, fontSize: 40),
                ),
                Text(
                  "POS",
                  style: AppStyling.semi35Black
                      .copyWith(color: AppColors.darkBlue, fontSize: 40),
                ),
              ],
            ),
            2.verticalSpace,
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: AppColors.whiteColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_bloc];
  }
}
