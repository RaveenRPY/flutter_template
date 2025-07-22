import 'package:AventaPOS/features/presentation/views/login/login_view.dart';
import 'package:AventaPOS/features/presentation/views/new_sale/process_payment_view.dart';
import 'package:AventaPOS/features/presentation/views/splash/splash_view.dart';
import 'package:flutter/material.dart';

import '../features/presentation/views/home/home_view.dart';
import 'app_colors.dart';
import 'app_stylings.dart';

class Routes {
  static const String kSplashView = "kSplashView";
  static const String kSaleView = "kSaleView";
  static const String kLoginView = "kLoginView";
  static const String kPaymentView = "kPaymentView";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case Routes.kSplashView:
        page = const SplashView();
        break;
      case Routes.kSaleView:
        page = const SaleView();
        break;
      case Routes.kLoginView:
        page = const LoginView();
        break;
      case Routes.kPaymentView:
        page =  ProcessPaymentView(params: settings.arguments as PaymentParams,);
        break;
      default:
        page = Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: Center(
            child: Text(
              "Invalid Route",
              style: AppStyling.regular14Grey.copyWith(
                color: AppColors.blackColor,
              ),
            ),
          ),
        );
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }
}
