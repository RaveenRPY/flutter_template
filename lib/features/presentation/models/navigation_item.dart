import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class NavigationItem {
  final IconData icon;
  final Routes? route;

  NavigationItem({
    required this.icon,
    this.route,
  });
} 