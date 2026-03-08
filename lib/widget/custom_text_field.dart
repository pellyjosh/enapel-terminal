import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final Color? labelTextColor;
  final String hintText;
  final bool obscureText, readOnly;
  final bool? enabled;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  // Dropdown-specific properties
  final List<String>? dropdownItems;
  final String? selectedDropdownValue;
  final ValueChanged<String?>? onDropdownChanged;

  // Additional customization
  final bool isSearchField;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed, onTap;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintTextColor;


  const CustomTextField({
    super.key,
    this.labelText,
    this.labelTextColor,
    required this.hintText,
    this.hintTextColor,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.dropdownItems,
    this.selectedDropdownValue,
    this.onDropdownChanged,
    this.onFieldSubmitted,
    this.isSearchField = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.fillColor,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.readOnly = false,
    this.onTap,
    this.enabled,
    this.backgroundColor,
    this.textColor,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally render the label if it is not null or empty
        if (widget.labelText != null && widget.labelText!.isNotEmpty) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              color: widget.labelTextColor ?? AppColor.black.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // TextField or Dropdown
        if (widget.dropdownItems == null) ...[
          TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            readOnly: widget.readOnly,
            enabled: widget.enabled ?? true,
            onTap: widget.onTap,
            style: TextStyle(color: widget.textColor ?? AppColor.black),
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor ?? AppColor.white.withOpacity(0.2),
              hintText: widget.hintText,
            hintStyle: TextStyle(
                color: widget.hintTextColor ??
                    widget.labelTextColor?.withOpacity(0.6) ??
                    AppColor.black.withOpacity(0.5),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.grey, width: 1),
              ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
              prefixIcon: widget.isSearchField
                  ? Icon(Icons.search, color: AppColor.black)
                  : (widget.prefixIcon != null
                      ? Icon(widget.prefixIcon, color: AppColor.black)
                      : null),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColor.black,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                  : (widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(widget.suffixIcon, color: AppColor.black),
                          onPressed: widget.onSuffixIconPressed,
                        )
                      : null),
            ),
            validator: widget.validator,
          )
        ] else ...[
          DropdownButtonFormField<String>(
            value: widget.selectedDropdownValue,
            onChanged: widget.onDropdownChanged,
            items: widget.dropdownItems!.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(color: widget.textColor ?? AppColor.black),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor ?? AppColor.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: AppColor.grey, width: 1),
              ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
              labelStyle: TextStyle(
                color: widget.textColor ?? AppColor.black, // Color for label
              ),
         hintStyle: TextStyle(
                color: widget.hintTextColor ??
                    (widget.textColor ?? AppColor.black).withOpacity(0.6),
              ),


            ),
            dropdownColor: widget.backgroundColor ?? AppColor.black,
          ),
        ],
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
