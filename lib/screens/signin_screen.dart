import 'package:flutter/material.dart';
import 'package:taxi_app/screens/homepage.dart';
import 'package:taxi_app/screens/signup_screen.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';
import 'components/social_button.dart';
import 'forgot_password_screen.dart';
import 'package:taxi_app/language/localization.dart'; // استيراد AppLocalizations

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // استخدام الترجمة من AppLocalizations
    String signInText = AppLocalizations.of(context).translate('sign_in');
    String emailHintText = AppLocalizations.of(context).translate('email_or_phone');
    String passwordHintText = AppLocalizations.of(context).translate('enter_password');
    String forgetPasswordText = AppLocalizations.of(context).translate('forget_password');
    String signUpText = AppLocalizations.of(context).translate('dont_have_account');
    String signUpLinkText = AppLocalizations.of(context).translate('sign_up');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
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
                    signInText,  // النص هنا سيكون مترجمًا
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: emailHintText,  // الترجمة هنا
                    controller: emailController,
                    width: double.infinity,
                    hintTextColor: theme.hintColor,
                    textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: passwordHintText,  // الترجمة هنا
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
                        forgetPasswordText,  // الترجمة هنا
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomButton(
                    text: signInText,  // الترجمة هنا
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
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: signUpText,  // الترجمة هنا
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          children: [
                            TextSpan(
                              text: signUpLinkText,  // الترجمة هنا
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
