import 'package:flutter/material.dart';

class AppColors {
  ///Colors
  static const Color primaryColor = Color(0xff4FB7E4);
  static const Color darkBlue = Color(0xff155c8e);
  static const Color whiteColor = Color(0xffffffff);
  static const Color blackColor = Color(0xff2B2B2B);
  static const Color lightGrey = Color(0xffF7F7F9);
  static const Color bgColor = Color(0xffEAF4FE);
  static const Color darkGrey = Color(0xff707B81);
  static const Color lineSeparationColor = Color(0xff6A6A6A);
  static const Color errorColor = Color(0xFFFF2212);
  static const Color yellowColor = Color(0xFFF6FF00);
  static const Color transparent = Colors.transparent;
  static const Color orangeColor = Color.fromRGBO(255, 101, 0, 1.0);
  static const Color darkYellowColor = Color(0xff806800);
  static const Color darkGreen = Color(0xff005e14);
  static const Color darkRed = Color(0xff880c00);

  /// ShortCut Button Colors
  static const Color lightBlue = Color(0xff39AFD1);
  static const Color lightPink = Color(0xffFA5C7C);
  static const Color lightGreen = Color(0xff00D459);
  static const Color green = Color(0xff00ca2b);
  static const Color red = Color(0xffEA4335);
  static const Color purple = Color(0xffcb67ff);
  static const Color darkPurple = Color(0xff640295);
  static const Color yellow = Color(0xffFFCC00);
  static const Color darkPink = Color(0xffFF2D55);

  static const RadialGradient appBarGradient = RadialGradient(
    colors: [Color(0xff287efd), Color(0xff084297)],
    stops: [0, 1],
    center: Alignment(-0.54, 0.7),
    radius: 1,
  );
  static const RadialGradient fabGradient = RadialGradient(
    colors: [Color(0xff287efd), Color(0xff084297)],
    stops: [0, 1],
    center: Alignment(0, 0),
    radius: 1,
  );
}
