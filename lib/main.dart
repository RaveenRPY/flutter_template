import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'core/my_app.dart';
import 'core/services/dependency_injection.dart' as di;
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: const MyApp(),
        );
      },
    ),
  );
}
