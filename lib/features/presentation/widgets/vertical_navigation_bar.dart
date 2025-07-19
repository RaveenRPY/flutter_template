import 'package:AventaPOS/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_stylings.dart';
import '../models/navigation_item.dart';

class VerticalNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<NavigationItem> items;

  const VerticalNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
      ),
      child: Column(
        children: [
          // App Logo/Title Section
          SizedBox(
            height: 90,
            child: Center(
              child: SvgPicture.asset(AppImages.logo),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return _NavigationItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          // Bottom Section (User Profile, Settings, etc.)
          Column(
            children: [
              _NavigationItem(item: NavigationItem(icon: HugeIcons.strokeRoundedSettings01), isSelected: false, onTap: () {},),
              Container(
                padding: EdgeInsets.fromLTRB(10,5,10,30),
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: (){},
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withOpacity(0.2),
                        shape: BoxShape.circle
                      ),
                      child: Icon(
                        size: 20,
                        Icons.logout,
                        color: AppColors.red
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.bgColor.withOpacity(1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: isSelected
                    ? Border.all(color: AppColors.primaryColor, width: 1)
                    : null,
              ),
              // child: SvgPicture.asset(
              child: Icon(
                // HugeIcons.strokeRoundedShoppingCartCheckIn02,
                // HugeIcons.strokeRoundedReturnRequest,
                // HugeIcons.strokeRoundedReturnRequest,
                item.icon,
                size: 20,
                color: isSelected
                    ? AppColors.darkBlue
                    : AppColors.whiteColor.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
