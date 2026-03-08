import 'package:enapel/widget/custom_button.dart';
import 'package:flutter/material.dart';

class DynamicListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final List<Widget>? children; // Additional widgets like columns or rows
  final bool isEven; // New property to alternate row colors
  final bool showButtons; // New property to control visibility of buttons

  const DynamicListItem({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.backgroundColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.children,
    required this.isEven, // Make it required
    this.showButtons = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isEven ? Colors.white : Colors.black), // Alternate colors
          borderRadius: borderRadius ?? BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) leading!,
                if (leading != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) title!,
                      if (subtitle != null) subtitle!,
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (children != null) ...[const SizedBox(height: 8), ...children!],
            if (showButtons) ...[
             const CustomButton()
            ],
          ],
        ),
      ),
    );
  }
}
