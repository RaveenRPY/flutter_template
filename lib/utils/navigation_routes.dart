import 'package:flutter/material.dart';

import '../features/presentation/views/sample/sample_view.dart';
import '../features/presentation/views/home/home_view.dart';
import 'app_colors.dart';
import 'app_stylings.dart';

class Routes {
  static const String kSampleView = "kSampleView";
  static const String kSaleView = "kSaleView";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case Routes.kSampleView:
        page = const SampleView();
        break;
      case Routes.kSaleView:
        page = const SaleView();
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
