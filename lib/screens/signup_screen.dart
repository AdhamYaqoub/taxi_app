import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isPrivacyAccepted = false;

  Future<void> signUp(String fullName, String phone) async {
    final url = Uri.parse('http://localhost:5000/signup');  // تأكد من أن URL يشير إلى السيرفر الخاص بك.

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'fullName': fullName,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      // تم إنشاء المستخدم بنجاح
      print('User created successfully');
      // يمكن الانتقال إلى شاشة أخرى بعد التسجيل
      Navigator.pushNamed(context, '/otp-verification');  // على سبيل المثال
    } else {
      // حدث خطأ
      print('Failed to create user: ${response.body}');
    }
  }

  void _onSignUpPressed() {
    if (isPrivacyAccepted) {
      signUp(
        fullNameController.text,  // استخدم المدخلات الخاصة بالمستخدم هنا
        phoneController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must accept the Privacy Policy and Terms & Conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            // حقل الاسم
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                hintText: "Full Name",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),
            // حقل رقم الجوال
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),
            // زر التسجيل
            ElevatedButton(
              onPressed: _onSignUpPressed,  // استدعاء دالة التسجيل
              child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            // إضافة خيار سياسة الخصوصية
            Row(
              children: [
                Checkbox(
                  value: isPrivacyAccepted,
                  onChanged: (value) {
                    setState(() {
                      isPrivacyAccepted = value!;
                    });
                  },
                ),
                Text("I accept the Privacy Policy and Terms & Conditions"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
