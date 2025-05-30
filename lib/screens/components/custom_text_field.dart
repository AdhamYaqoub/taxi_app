// في ملف components/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final double width;
  final bool obscureText;
  final IconData? suffixIcon; // يمكن أن تكون أيقونة أو لا
  final VoidCallback? onSuffixPressed; // لتشغيل الـ suffixIcon
  final TextInputType keyboardType;
  final Color hintTextColor;
  final Color textColor;
  final IconData? prefixIcon; // **الخاصية الجديدة**

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.width,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
    this.keyboardType = TextInputType.text,
    required this.hintTextColor,
    required this.textColor,
    this.prefixIcon, // **إضافة للـ constructor**
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: hintTextColor),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
              Colors.grey[200], // لون خلفية الحقل
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // حواف دائرية
            borderSide:
                BorderSide(color: hintTextColor.withOpacity(0.5)), // حدود خفيفة
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: hintTextColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor), // لون التركيز
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: hintTextColor)
              : null, // **استخدام الـ prefixIcon**
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: hintTextColor),
                  onPressed: onSuffixPressed,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 15), // تعديل الـ padding الداخلي
        ),
      ),
    );
  }
}
