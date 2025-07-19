import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';

class PopupWindow extends StatefulWidget {
  const PopupWindow({super.key});

  @override
  State<PopupWindow> createState() => _PopupWindowState();
}

class _PopupWindowState extends State<PopupWindow> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(25),
        child: Material(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(30),
          child: Wrap(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 2.8.h, horizontal: 2.6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context) {
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
              child: PopupWindow(),
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
