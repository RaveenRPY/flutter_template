import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_stylings.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final Color? color;
  final TextStyle? textStyle;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 100), this.color = AppColors.whiteColor, this.textStyle,
  });

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String displayedText = '';
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    timer = Timer.periodic(widget.duration, (timer) {
      if (currentIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: widget.textStyle ?? AppStyling.bold18Black.copyWith(color: widget.color,fontStyle: FontStyle.italic, fontSize: 20.dp),
    );
  }
}