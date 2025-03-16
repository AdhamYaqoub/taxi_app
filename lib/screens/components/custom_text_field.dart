import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextEditingController controller;
  final double width;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    required this.controller,
    required this.width, required Color hintTextColor, required Color textColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // لون النص يتغير حسب الثيم
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54), // لون التلميح يتغير
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, // لون الخلفية حسب الثيم
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: isDarkMode ? Colors.white70 : Colors.black54)
              : null,
        ),
      ),
    );
  }
}
