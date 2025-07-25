import 'dart:ui';

import 'package:AventaPOS/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_stylings.dart';
import 'app_main_button.dart';

class AppDialogBox extends StatelessWidget {
  final String? title;
  final String? message;
  final String? image;
  final bool? isTwoButton;
  final String? negativeButtonText;
  final String? positiveButtonText;
  final Function? positiveButtonTap;
  final Function? negativeButtonTap;

  const AppDialogBox({
    super.key,
    this.title,
    this.message,
    this.image,
    this.isTwoButton = true,
    this.negativeButtonText,
    this.positiveButtonText,
    this.positiveButtonTap,
    this.negativeButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        alignment: FractionalOffset.center,
        padding: EdgeInsets.all(20.sp),
        child: Material(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 48.h,
            constraints: BoxConstraints(maxWidth: 60.w, maxHeight: 70.h),
            child: Wrap(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 2.8.h, horizontal: 2.6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      2.verticalSpace,
                      Center(
                        child: Lottie.asset(
                          image ?? AppImages.successDialog,
                          frameRate: const FrameRate(120),
                          height: 35.sp,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        title ?? '',
                        style: AppStyling.medium16Black,
                      ),
                      1.verticalSpace,
                      Text(
                        message ?? '',
                        textAlign: TextAlign.center,
                        style: AppStyling.regular14Black.copyWith(fontSize: 11.sp),
                      ),
                      3.verticalSpace,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isTwoButton!)
                            Expanded(
                              child: AppMainButton(
                                title: negativeButtonText ?? '',
                                color: AppColors.darkGrey.withOpacity(0.15),
                                titleStyle: AppStyling.medium14Black.copyWith(
                                    color: AppColors.darkGrey,
                                    fontSize: 11.5.sp, height: 1),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                  negativeButtonTap!();
                                },
                              ),
                            ),
                          if (isTwoButton!) SizedBox(width: 10),
                          Expanded(
                            child: AppMainButton(
                              title: positiveButtonText ?? 'Done',
                              titleStyle: AppStyling.medium14Black.copyWith(
                                  color: AppColors.whiteColor,
                                  fontSize: 11.5.sp, height: 1),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                                positiveButtonTap!();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String? title,
    String? message,
    String? image,
    bool isTwoButton = true,
    String? negativeButtonText,
    String? positiveButtonText,
    VoidCallback? negativeButtonTap,
    VoidCallback? positiveButtonTap,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: false,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: PopScope(
              canPop: false,
              child: AppDialogBox(
                title: title,
                message: message,
                image: image,
                negativeButtonText: negativeButtonText,
                negativeButtonTap: negativeButtonTap,
                positiveButtonText: positiveButtonText,
                positiveButtonTap: positiveButtonTap,
                isTwoButton: isTwoButton,
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return const SizedBox.shrink();
      },
    );
  }
}
