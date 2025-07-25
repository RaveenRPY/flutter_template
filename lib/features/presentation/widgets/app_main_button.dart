import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_stylings.dart';

class AppMainButton extends StatefulWidget {
  GestureTapCallback? onTap;
  String title;
  Color? color;
  TextStyle? titleStyle;
  bool? isEnable;
  bool? isNegative;
  Widget? prefixIcon;
  double? width;
  double? borderRadius;

  AppMainButton({
    super.key,
    this.onTap,
    required this.title,
    this.color = AppColors.primaryColor,
    this.isEnable = true,
    this.isNegative = false,
    this.titleStyle,
    this.prefixIcon,
    this.width,
    this.borderRadius,
  });

  @override
  State<AppMainButton> createState() => _AppMainButtonState();
}

class _AppMainButtonState extends State<AppMainButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        style:
            widget.isNegative!
                ? ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 60,
                      ),
                    ),
                  ),
                  fixedSize: const WidgetStatePropertyAll(Size.infinite),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 1.7.h, horizontal: 16),
                  ),
                  splashFactory: InkRipple.splashFactory,
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.darkGrey.withOpacity(0.15),
                  ),
                  backgroundColor:
                      widget.isEnable!
                          ? WidgetStatePropertyAll(
                            AppColors.darkGrey.withOpacity(0.3),
                          )
                          : WidgetStatePropertyAll(
                            AppColors.darkGrey.withOpacity(0.3),
                          ),
                  elevation: const WidgetStatePropertyAll(0),
                )
                : ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 60,
                      ),
                    ),
                  ),
                  fixedSize: const WidgetStatePropertyAll(Size.infinite),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 1.7.h, horizontal: 16),
                  ),
                  splashFactory: InkRipple.splashFactory,
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.whiteColor.withOpacity(0.15),
                  ),
                  backgroundColor:
                      widget.isEnable!
                          ? WidgetStatePropertyAll(widget.color)
                          : WidgetStatePropertyAll(
                            AppColors.darkGrey.withOpacity(0.3),
                          ),
                  elevation: const WidgetStatePropertyAll(0),
                ),
        onPressed: widget.isEnable! ? widget.onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.prefixIcon ?? const SizedBox(),
              widget.prefixIcon != null
                  ? const SizedBox(width: 5)
                  : const SizedBox(),
              Text(
                widget.title,
                style:
                    !widget.isNegative!
                        ? widget.isEnable!
                            ? widget.titleStyle ?? AppStyling.medium14White.copyWith(fontSize: 11.5.sp, height: 1)
                            : AppStyling.medium14White.copyWith(fontSize: 11.5.sp,height: 1)
                        : widget.titleStyle ?? AppStyling.medium14Black.copyWith(fontSize: 11.5.sp,height: 1),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
