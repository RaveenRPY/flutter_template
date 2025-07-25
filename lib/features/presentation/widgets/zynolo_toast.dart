import 'dart:async';
import 'dart:ui';

import 'package:AventaPOS/features/presentation/widgets/typewriter_text.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_stylings.dart';
import '../../../utils/enums.dart';

enum Position {
  top,
  bottom,
}

enum AnimationType {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

enum ToastLayout {
  ltr,
  rtl,
}

class ZynoloToast extends StatefulWidget {
  final String? title;
  final Text? description;
  final Text? action;
  final Color backgroundColor;
  final Color shadowColor;
  final Widget? iconWidget;
  final double iconSize;
  final Position toastPosition;
  final Duration animationDuration;
  final Cubic animationCurve;
  final AnimationType animationType;
  final bool autoDismiss;
  final Duration toastDuration;
  final ToastLayout layout;
  final bool displayCloseButton;
  final double borderRadius;
  final bool displayIcon;
  final bool enableIconAnimation;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool disableToastAnimation;
  final bool inheritThemeColors;
  final Function()? onToastClosed;
  final Toast? toastType;

  static DateTime? _lastToastTime;
  static const int _toastGapSeconds = 4;

  ZynoloToast({
    super.key,
    this.title,
    this.action,
    this.backgroundColor = Colors.white,
    this.shadowColor = AppColors.darkGrey,
    this.description,
    this.iconWidget,
    this.toastPosition = Position.top,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.toastDuration = const Duration(milliseconds: 3000),
    this.layout = ToastLayout.ltr,
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.iconSize = 20,
    this.height,
    this.width,
    this.constraints,
    this.disableToastAnimation = false,
    this.inheritThemeColors = false,
    this.onToastClosed,
    this.toastType,
  }) {
    assert(title != null || description != null);
  }

  void show(BuildContext context) {
    final now = DateTime.now();
    if (_lastToastTime != null &&
        now.difference(_lastToastTime!).inSeconds < _toastGapSeconds) {
      return;
    }
    _lastToastTime = now;
    overlayEntry = _overlayEntryBuilder();
    final overlay = Overlay.maybeOf(context);

    if (overlay != null) {
      overlay.insert(overlayEntry!);
    } else {
      Navigator.of(context).overlay?.insert(overlayEntry!);
    }
  }

  void closeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  OverlayEntry? overlayEntry;

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      opaque: false,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: const EdgeInsets.all(5),
            insetPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            alignment: Alignment.topCenter,
            content: this,
          ),
        );
      },
    );
  }

  @override
  _ZynoloToastState createState() => _ZynoloToastState();
}

class _ZynoloToastState extends State<ZynoloToast>
    with TickerProviderStateMixin {
  late Animation<Offset> offsetAnimation;
  late Animation<Offset> disabledAnimationOffset;
  late AnimationController slideController;
  late BoxDecoration toastDecoration;
  Timer? autoDismissTimer;

  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    initAnimation();

    toastDecoration = BoxDecoration(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        _createToastBoxShadow(color: widget.shadowColor),
      ],
    );
    if (widget.autoDismiss) {
      autoDismissTimer = Timer(widget.toastDuration, () {
        if (!widget.disableToastAnimation) {
          slideController.reverse();
        }
        Timer(widget.animationDuration, () {
          widget.closeOverlay();
        });
      });
    }

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _toggleContainer();
  }

  _toggleContainer() async {
    if (_animation?.status != AnimationStatus.completed) {
      await Future.delayed(const Duration(milliseconds: 500));
      _controller?.forward();
      await Future.delayed(
          Duration(milliseconds: widget.toastDuration.inMilliseconds - 1500));
      _controller?.animateBack(0, duration: const Duration(seconds: 1));
    } else {
      _controller?.animateBack(0, duration: const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    widget.onToastClosed?.call();
    autoDismissTimer?.cancel();
    if (!widget.disableToastAnimation) {
      slideController.dispose();
    }
    super.dispose();
  }

  void initAnimation() {
    slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    if (widget.disableToastAnimation) {
      disabledAnimationOffset = Tween<Offset>(
        begin: const Offset(0, 0),
        end: const Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: slideController,
          curve: widget.animationCurve,
        ),
      );
    } else {
      switch (widget.animationType) {
        case AnimationType.fromLeft:
          offsetAnimation = Tween<Offset>(
            begin: const Offset(-2, 0),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: slideController,
              curve: widget.animationCurve,
            ),
          );
          break;
        case AnimationType.fromRight:
          offsetAnimation = Tween<Offset>(
            begin: const Offset(2, 0),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: slideController,
              curve: widget.animationCurve,
            ),
          );
          break;
        case AnimationType.fromTop:
          offsetAnimation = Tween<Offset>(
            begin: const Offset(0, -2),
            end: const Offset(0, 0.6),
          ).animate(
            CurvedAnimation(
              parent: slideController,
              curve: widget.animationCurve,
            ),
          );
          break;
        case AnimationType.fromBottom:
          offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: slideController,
              curve: widget.animationCurve,
            ),
          );
          break;
        default:
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.disableToastAnimation) {
        slideController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.disableToastAnimation
          ? disabledAnimationOffset
          : offsetAnimation,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: renderCherryToastContent(context),
      ),
    );
  }

  Widget renderCherryToastContent(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              _createToastBoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
            ],
          ),
          constraints: widget.constraints,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: widget.backgroundColor.withOpacity(0.9),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getToastIcon(widget.toastType),
                          renderToastContent(),
                          // if (widget.displayCloseButton)
                          //   renderCloseButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getToastIcon(Toast? type) {
    switch (type) {
      case Toast.success:
        return toastIcon(
            color: AppColors.green, icon: Icons.check_circle_outline_rounded);
      case Toast.failed:
        return toastIcon(color: AppColors.red, icon: Icons.cancel_outlined);
      case Toast.warning:
        return toastIcon(
            color: AppColors.orangeColor, icon: Icons.error_outline_rounded);
      default:
        return toastIcon(
            color: AppColors.primaryColor,
            icon: Icons.check_circle_outline_rounded,
            isDefault: true);
    }
  }

  Widget toastIcon(
      {required Color color, required IconData icon, bool? isDefault = false}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: !isDefault!
          ? Icon(
              icon,
              color: AppColors.whiteColor,
            )
          : const Padding(
              padding: EdgeInsets.all(3.0),
              child: ImageIcon(
                AssetImage(AppImages.logo),
                color: AppColors.whiteColor,
                size: 20,
              ),
            ),
    );
  }

  Widget renderToastContent() {
    return SizeTransition(
      sizeFactor: _animation!,
      axis: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 9, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: widget.layout == ToastLayout.ltr
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.end,
          children: [
            if (widget.title != null)
              TypewriterText(
                text: widget.title ?? '',
                duration: const Duration(milliseconds: 1),
                textStyle: AppStyling.medium12Black
                    .copyWith(fontSize: 11.sp, height: 2),
              ),
          ],
        ),
      ),
    );
  }

  BoxShadow _createToastBoxShadow({
    required Color color,
  }) =>
      BoxShadow(
        color: color,
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      );
}
