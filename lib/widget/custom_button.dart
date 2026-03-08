import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text; // Main text on the button
  final Widget? child; // Fully custom child (overrides text and icon)
  final VoidCallback? onPressed; // Nullable for disabled state
  final ButtonStyle? style; // Style for button
  final Widget? icon; // Optional icon
  final FocusNode? focusNode; // Focus node for button
  final bool autofocus; // Whether the button should be autofocus
  final Clip clipBehavior; // Clipping behavior
  final String? label; // Optional label text inside the button
  final TextStyle? textStyle; // Style for button text
  final TextStyle? labelStyle; // Style for the label text
  final bool disabled; // New parameter to explicitly disable the button

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.style,
    this.icon,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.label,
    this.textStyle,
    this.labelStyle,
    this.disabled = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDisabled = disabled || onPressed == null;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? AppColor.grey : AppColor.black,
            foregroundColor: AppColor.white,
            padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.015, // Adjusted vertical padding
              horizontal: screenWidth * 0.04, // Adjusted horizontal padding
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(
              screenWidth * 0.2, // Responsive minimum width
              screenWidth * 0.05, // Responsive minimum height
            ),
          ),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child ??
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) icon!,
              if (icon != null && (text != null || label != null))
                SizedBox(width: screenWidth * 0.005), // Reduced spacing
              if (text != null)
                Text(
                  text!,
                  style: textStyle ??
                      TextStyle(
                        fontSize: screenWidth * 0.03, // Responsive font size
                        color: isDisabled
                            ? AppColor.black.withOpacity(0.7)
                            : AppColor.white,
                      ),
                ),
              if (label != null)
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.005), // Reduced spacing
                  child: Text(
                    label!,
                    style: labelStyle ??
                        TextStyle(
                          fontSize:
                              screenWidth * 0.012, // Responsive label font size
                          color: isDisabled
                              ? AppColor.black.withOpacity(0.5)
                              : AppColor.white,
                        ),
                  ),
                ),
            ],
          ),
    );
  }
}
