import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';

class AppStyling {
  ///--------------------- Poppins -----------------------------

  /// fontSize - 8
  static TextStyle regular8Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 8,
    color: AppColors.darkBlue,
  );
  static TextStyle medium8Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 8,
    color: AppColors.darkGrey,
  );
  static TextStyle medium8Pink = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 8,
    color: AppColors.primaryColor,
  );

  /// fontSize - 9
  static TextStyle medium9Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 8,
    color: AppColors.darkBlue,
  );

  /// fontSize - 10
  static TextStyle regular10Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: AppColors.darkGrey,
  );
  static TextStyle regular10Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: AppColors.darkBlue,
  );
  static TextStyle medium10Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: AppColors.darkBlue,
  );
  static TextStyle semi10Pink = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 10,
    color: AppColors.primaryColor,
  );
  static TextStyle medium10Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: AppColors.darkGrey,
  );

  /// fontSize - 12
  static TextStyle regular12White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.whiteColor,
  );
  static TextStyle regular12Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.darkBlue,
  );
  static TextStyle regular12Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.darkGrey,
  );
  static TextStyle medium12Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.darkGrey,
  );
  static TextStyle medium12Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.darkBlue,
  );
  static TextStyle medium12White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.whiteColor,
  );
  static TextStyle semi12Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.darkBlue,
  );

  /// fontSize - 14
  static TextStyle regular14Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.darkGrey,
  );
  static TextStyle regular14Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.darkBlue,
  );
  static TextStyle medium14Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.darkBlue,
  );
  static TextStyle medium14White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.whiteColor,
  );
  static TextStyle semi14Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.darkBlue,
  );
  static TextStyle semi14White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.whiteColor,
  );

  /// fontSize - 16
  static TextStyle regular16Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.darkGrey,
  );
  static TextStyle medium16Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.darkBlue,
  );
  static TextStyle semi16Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.darkBlue,
  );

  /// fontSize - 18
  static TextStyle regular18Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.darkBlue,
  );
  static TextStyle medium18Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.darkBlue,
  );
  static TextStyle bold18White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.whiteColor,
  );
  static TextStyle bold18Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.darkBlue,
  );

  /// fontSize - 20
  static TextStyle medium20Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: AppColors.darkBlue,
  );
  static TextStyle medium20White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: AppColors.whiteColor,
  );
  static TextStyle semi20White = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.whiteColor,
  );
  static TextStyle semi20Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.darkBlue,
  );

  /// fontSize - 22
  static TextStyle medium22Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 22,
    color: AppColors.darkBlue,
  );
  static TextStyle semi22Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: AppColors.darkBlue,
  );

  /// fontSize - 25
  static TextStyle medium25Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 25,
    color: AppColors.darkBlue,
  );
  static TextStyle semi25Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 25,
    color: AppColors.darkBlue,
  );
  static TextStyle semi25Grey = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 25,
    color: AppColors.darkGrey,
  );

  /// fontSize - 35
  static TextStyle medium35Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 35,
    color: AppColors.darkBlue,
  );
  static TextStyle semi35Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 35,
    color: AppColors.darkBlue,
  );

  /// fontSize - 65
  static TextStyle semi65Black = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 65,
    color: AppColors.darkBlue,
  );
}
