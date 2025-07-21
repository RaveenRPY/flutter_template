import 'dart:developer';

import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_stylings.dart';
import '../../domain/entities/data.dart';

class ZynoloDropdown extends StatefulWidget {
  final String? hintText;
  final List<Data>? items;
  final Function? onChanged;
  final bool? isEnabled;
  final SingleSelectController<Data>? controller;

  const ZynoloDropdown({
    super.key,
    this.hintText,
    this.items,
    this.onChanged,
    this.isEnabled = true,
    this.controller,
  });

  @override
  State<ZynoloDropdown> createState() => _ZynoloDropdownState();
}

class _ZynoloDropdownState extends State<ZynoloDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownFlutter<Data>(
      hintText: widget.hintText,
      items: widget.items,
      enabled: widget.isEnabled!,
      controller: widget.controller,
      disabledDecoration: CustomDropdownDisabledDecoration(
        headerStyle: AppStyling.medium14Black,
        fillColor: AppColors.darkGrey.withOpacity(0.08),
        hintStyle: AppStyling.regular12Grey.copyWith(
          color: AppColors.darkGrey.withOpacity(0.4),
          height: 1.5
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.0),
          width: 1.5,
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: AppColors.darkGrey.withOpacity(0.4),
        ),
      ),
      decoration: CustomDropdownDecoration(
        headerStyle: AppStyling.medium14Black,
        closedSuffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: AppColors.darkGrey,
        ),
        errorStyle: AppStyling.regular10Black.copyWith(
          color: AppColors.errorColor,
        ),
        overlayScrollbarDecoration: ScrollbarThemeData(
          radius: Radius.circular(20),
          thumbVisibility: WidgetStatePropertyAll(true),
        ),
        closedErrorBorder: Border.all(color: AppColors.errorColor, width: 1.5),
        closedErrorBorderRadius: BorderRadius.circular(15),
        closedFillColor: AppColors.darkGrey.withOpacity(0.08),
        hintStyle: AppStyling.regular12Grey.copyWith(height: 1.5),
        closedBorder: Border.all(
          color: AppColors.darkGrey.withOpacity(0.1),
          width: 1.5,
        ),
        closedBorderRadius: BorderRadius.circular(15),
      ),
      headerBuilder: (context, item, isSelected) {
        return Text(
          item.description ?? '',
          style:
              isSelected
                  ? AppStyling.medium14Black
                  : AppStyling.regular14Black,
        );
      },
      listItemBuilder: (context, item, isSelected, widget) {
        return Text(
          item.description ?? '',
          style:
              isSelected
                  ? AppStyling.medium14Black
                  : AppStyling.regular14Black,
        );
      },
      validateOnChange: true,
      validator: (value) {
        return value == null
            ? widget.isEnabled!
                ? "Must not be empty"
                : null
            : null;
      },
      onChanged: (value) {
        widget.onChanged!(value?.code);
      },
      overlayHeight: ((widget.items?.length)! * 45).toDouble(),
    );
  }
}
