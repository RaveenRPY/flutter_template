import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../utils/app_colors.dart';
import '../../../utils/app_stylings.dart';
import '../../../utils/app_validator.dart';

class AventaFormField extends StatefulWidget {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final bool isObsecure;
  final bool? isEnable;
  final bool? isReadOnly;
  final bool? isParagraph;
  final bool? isForEdit;
  final Color? prefixIconColor;
  final Color? filledColor;
  final String? hintText;
  final String? label;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final GestureTapCallback? onTap;
  final TextInputType? textInputType;
  final int? maxLength;
  final String? counterText;
  final TextCapitalization? textCapitalization;
  final Function? onCompleted;
  final Function(String)? onChanged;

  // New currency-related parameters
  final bool isCurrency;
  final bool showCurrencySymbol;
  final FocusNode? focusNode;

  const AventaFormField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.prefixIconColor,
    this.isObsecure = false,
    this.hintText,
    this.label,
    this.isForEdit = false,
    this.inputFormatters,
    this.validator,
    this.filledColor,
    this.onTap,
    this.isEnable = true,
    this.isReadOnly = false,
    this.isParagraph = false,
    this.textInputType = TextInputType.text,
    this.maxLength,
    this.counterText,
    this.textCapitalization,
    this.isCurrency = false,
    this.showCurrencySymbol = true,
    this.onCompleted,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<AventaFormField> createState() => _AventaFormFieldState();
}

class _AventaFormFieldState extends State<AventaFormField> {
  late bool isPasswordHide;
  late FocusNode _focusNode;

  MoneyMaskedTextController? _moneyMaskedTextController;
  TextStyle _labelStyle = AppStyling.regular12Grey.copyWith(
    color: AppColors.darkGrey,
  );

  @override
  void initState() {
    super.initState();
    isPasswordHide = widget.isObsecure;

    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize money masked controller for currency
    if (widget.isCurrency) {
      _moneyMaskedTextController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: ',',
        initialValue: widget.controller.text.isEmpty
            ? null
            : double.tryParse(widget.controller.text.replaceAll(",", "")),
      );

      // Add listener for currency field changes
      if (widget.onChanged != null) {
        _moneyMaskedTextController!.addListener(() {
          widget.onChanged!(_moneyMaskedTextController!.text);
        });
      }

      // Replace the original controller with money masked controller
      widget.controller.dispose();
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _labelStyle = _focusNode.hasFocus
          ? AppStyling.medium14Black.copyWith(
              color: AppColors.primaryColor,
            )
          : AppStyling.regular12Grey.copyWith(color: AppColors.darkGrey);
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _moneyMaskedTextController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onEditingComplete: () {
        if (widget.onCompleted != null) widget.onCompleted!();
      },
      onChanged: widget.onChanged,
      controller:
          widget.isCurrency ? _moneyMaskedTextController : widget.controller,
      keyboardType:
          widget.isCurrency ? TextInputType.number : widget.textInputType,
      maxLength: widget.maxLength,
      style: widget.isReadOnly!
          ? AppStyling.regular14Black
          : AppStyling.medium14Black,
      cursorColor: AppColors.primaryColor,
      cursorErrorColor: AppColors.errorColor,
      obscureText: isPasswordHide,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      enabled: widget.isEnable,
      focusNode: _focusNode,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      maxLines: widget.isParagraph! ? null : 1,
      onTap: widget.onTap,
      inputFormatters: [
        if (widget.inputFormatters != null) ...widget.inputFormatters!,
        // Prevent emoji input
        FilteringTextInputFormatter.deny(RegExp(AppValidator().emojiRegexp)),
      ],
      validator: widget.validator,
      readOnly: widget.isReadOnly!,
      decoration: InputDecoration(
        // Add currency prefix when in currency mode and focused
        prefix: widget.isCurrency && widget.showCurrencySymbol
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text('Rs', style: AppStyling.regular14Black),
              )
            : null,
        prefixIcon: widget.prefixIcon,
        counterText: widget.counterText,
        prefixIconColor: widget.prefixIconColor,
        errorMaxLines: 2,
        floatingLabelStyle: AppStyling.medium14Black.copyWith(
          color: _focusNode.hasFocus
              ? AppColors.primaryColor
              : !widget.isForEdit!
                  ? AppColors.darkGrey
                  : AppColors.primaryColor,
        ),
        hintStyle: AppStyling.regular12Grey.copyWith(
          color: AppColors.darkGrey,
        ),
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 1.9.h, horizontal: 2.h),
        labelText: widget.label,
        labelStyle: _labelStyle,
        focusColor: AppColors.primaryColor,
        // Password visibility toggle
        suffixIcon: widget.isObsecure
            ? Material(
                color: AppColors.transparent,
                child: InkWell(
                  radius: 8,
                  borderRadius: BorderRadius.circular(5),
                  highlightColor: AppColors.transparent,
                  splashColor: AppColors.primaryColor.withOpacity(0.4),
                  onTap: () {
                    setState(() {
                      isPasswordHide = !isPasswordHide;
                    });
                  },
                  child: Icon(
                    isPasswordHide ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                ),
              )
            : null,
        suffixIconColor: AppColors.primaryColor,
        filled: true,
        fillColor: widget.isEnable!
            ? widget.filledColor ?? AppColors.bgColor.withOpacity(0.0)
            : AppColors.darkGrey.withOpacity(0.05),
        errorStyle: AppStyling.regular10Black.copyWith(
          color: AppColors.errorColor,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        enabledBorder: (!widget.isReadOnly!)
            ? !widget.isForEdit!
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppColors.darkBlue.withOpacity(0.28),
                      width: 1.5,
                    ),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:  BorderSide(
                  color: AppColors.darkBlue.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: AppColors.darkGrey.withOpacity(0.2),
            width: 0.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // Helper method to get currency value
  double? getCurrencyValue() {
    if (widget.isCurrency) {
      return _moneyMaskedTextController?.numberValue;
    }
    return null;
  }
}
