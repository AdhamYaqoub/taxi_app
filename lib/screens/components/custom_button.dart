import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width; // استخدام double بدلاً من int للعرض

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.width, // تمرير عرض الزر
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // استخدام العرض المحدد هنا
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
