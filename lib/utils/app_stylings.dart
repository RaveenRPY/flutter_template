import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';

class AppStyling {
  ///--------------------- Poppins -----------------------------

  /// fontSize - 8
  static TextStyle regular8Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 10.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium8Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 10.px,
    color: AppColors.darkGrey,
  );
  static TextStyle medium8Pink = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 10.px,
    color: AppColors.primaryColor,
  );

  /// fontSize - 9
  static TextStyle medium9Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 11.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 10
  static TextStyle regular10Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 12.px,
    color: AppColors.darkGrey,
  );
  static TextStyle regular10Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 12.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium10Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 12.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi10Pink = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 12.px,
    color: AppColors.primaryColor,
  );
  static TextStyle medium10Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 12.px,
    color: AppColors.darkGrey,
  );

  /// fontSize - 12
  static TextStyle regular12White = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14.px,
    color: AppColors.whiteColor,
  );
  static TextStyle regular12Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14.px,
    color: AppColors.darkBlue,
  );
  static TextStyle regular12Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14.px,
    color: AppColors.darkGrey,
  );
  static TextStyle medium12Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 14.px,
    color: AppColors.darkGrey,
  );
  static TextStyle medium12Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 14.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium12White = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 14.px,
    color: AppColors.whiteColor,
  );
  static TextStyle semi12Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 14.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 14
  static TextStyle regular14Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16.px,
    color: AppColors.darkGrey,
  );
  static TextStyle regular14Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium14Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 16.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium14White = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 16.px,
    color: AppColors.whiteColor,
  );
  static TextStyle semi14Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi14White = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16.px,
    color: AppColors.whiteColor,
  );

  /// fontSize - 16
  static TextStyle regular16Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 18.px,
    color: AppColors.darkGrey,
  );
  static TextStyle medium16Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 18.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi16Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 18.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 18
  static TextStyle regular18Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 20.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium18Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 20.px,
    color: AppColors.darkBlue,
  );
  static TextStyle bold18White = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 20.px,
    color: AppColors.whiteColor,
  );
  static TextStyle bold18Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 20.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 20
  static TextStyle medium20Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 22.px,
    color: AppColors.darkBlue,
  );
  static TextStyle medium20White = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 22.px,
    color: AppColors.whiteColor,
  );
  static TextStyle semi20White = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 22.px,
    color: AppColors.whiteColor,
  );
  static TextStyle semi20Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 22.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 22
  static TextStyle medium22Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 24.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi22Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 24.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 25
  static TextStyle medium25Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 24.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi25Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 24.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi25Grey = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 24.px,
    color: AppColors.darkGrey,
  );

  /// fontSize - 35
  static TextStyle medium35Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 37.px,
    color: AppColors.darkBlue,
  );
  static TextStyle semi35Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 37.px,
    color: AppColors.darkBlue,
  );

  /// fontSize - 65
  static TextStyle semi65Black = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 67.px,
    color: AppColors.darkBlue,
  );
}
