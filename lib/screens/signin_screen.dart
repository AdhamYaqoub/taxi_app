import 'package:flutter/material.dart';
import 'package:taxi_app/screens/homepage.dart';
// import 'package:taxi_app/screens/pyment.dart';
import 'package:taxi_app/screens/signup_screen.dart';
// import 'package:taxi_app/theme/theme.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';
import 'components/social_button.dart';
import 'forgot_password_screen.dart';
// import 'maps_screen.dart';
// import 'about.dart';
// import '../screens/ProfileScreen.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String selectedLanguage = 'en'; // Define the selectedLanguage variable
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(selectedLanguage: selectedLanguage, hiddenButtons: ['login']),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // اعتبر الشاشة كبيرة إذا تجاوزت 600 بكسل
          return Center(
            child: Container(
              width: isWeb ? 400 : double.infinity, // وسط الشاشة في الويب
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: "Email or Phone Number",
                    controller: emailController,
                    width: double.infinity,
                    hintTextColor: theme.hintColor,
                    textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Enter Your Password",
                    obscureText: true,
                    suffixIcon: Icons.visibility_off,
                    controller: passwordController,
                    width: double.infinity,
                    hintTextColor: theme.hintColor,
                    textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
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
                      child: Text(
                        "Forget password?",
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
               CustomButton(
  text: "Sign In",
  width: double.infinity,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // الانتقال إلى الصفحة الرئيسية
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
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpScreen()), // استبدل SignUpScreen بالشاشة الصحيحة
      );
    },
    child: Text.rich(
      TextSpan(
        text: "Don’t have an account? ",
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        children: [
          TextSpan(
            text: "Sign Up",
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
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
        },
      ),
    );
  }
}