import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/navigation_routes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setImmersiveMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _setImmersiveMode();
    }
  }

  void _setImmersiveMode() {
    // Hide system UI (status bar and navigation bar)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
    );
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.kSplashView,
      debugShowCheckedModeBanner: true,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: null),
            child: child!,
          ),
      theme: ThemeData(
        canvasColor: AppColors.transparent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.whiteColor,
        // backgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor,
          selectionColor: AppColors.primaryColor.withOpacity(0.2),
          selectionHandleColor: AppColors.primaryColor,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          surfaceTintColor: Colors.transparent,
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(10.0),
          trackBorderColor: WidgetStateProperty.all(AppColors.lightGrey),
          thickness: WidgetStateProperty.all(6.0),
          thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
        ),
        splashColor: AppColors.primaryColor,
        highlightColor: AppColors.primaryColor,
        unselectedWidgetColor: AppColors.blackColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.whiteColor,
        ),
      ),
    );
  }
}
