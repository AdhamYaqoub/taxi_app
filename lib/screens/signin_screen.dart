import 'package:flutter/material.dart';
import 'package:taxi_app/screens/pyment.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';
import 'components/social_button.dart';
import 'forgot_password_screen.dart';
import 'maps_screen.dart'; // استيراد صفحة الخرائط
import 'about.dart'; // استيراد صفحة حول التطبيق
//import '../screens/SOS.dart'; // استيراد صفحة حول التطبيق
import '../screens/ProfileScreen.dart'; // استيراد صفحة حول التطبيق

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: Text("About", style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Sign in",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CustomTextField(
              hintText: "Email or Phone Number",
              controller: emailController,
            ),
            SizedBox(height: 15),
            CustomTextField(
              hintText: "Enter Your Password",
              obscureText: true,
              suffixIcon: Icons.visibility_off,
              controller: passwordController,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                  );
                },
                child: Text("Forget password?", style: TextStyle(color: Colors.red)),
              ),
            ),
            SizedBox(height: 10),
            CustomButton(
              text: "Sign In",
              onPressed: () {
                // الانتقال إلى صفحة الخرائط
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapsScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialButton(assetPath: "assets/image-removebg-preview4.png"),
                SizedBox(width: 15),
                SocialButton(assetPath: "assets/image-removebg-preview4.png"),
                SizedBox(width: 15),
                SocialButton(assetPath: "assets/image-removebg-preview5.png"),
              ],
            ),
            Spacer(),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
