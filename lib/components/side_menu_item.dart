import 'package:flutter/material.dart';

class SideMenuItem {
  const SideMenuItem({
    required this.iconData,
    required this.textLabel,
    required this.hoverColor,
    required this.path,
  });

  /// IconData to show before the label.
  final IconData iconData;

  /// Label's string value.
  final String textLabel;

  /// Icon's color when hovering the item.
  final Color hoverColor;

  /// Route path to go when tapping this item.
  final String path;
}
