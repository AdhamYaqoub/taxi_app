import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:taxi_app/screens/admin.dart';
import 'package:taxi_app/screens/driver_dashboard.dart'; // صفحة السائق
import 'package:taxi_app/screens/manegar.dart';
import 'package:taxi_app/screens/signup_screen.dart';
import 'package:taxi_app/screens/user.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';
import 'components/social_button.dart';
import 'forgot_password_screen.dart';
import 'package:taxi_app/language/localization.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn(BuildContext context) async {
    setState(() => isLoading = true);

    final String apiUrl = '${dotenv.env['BASE_URL']}/api/users/signin';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        // الوصول إلى بيانات المستخدم
        final user = data['user']; // احصل على البيانات من مفتاح 'user'

        if (user != null && user['role'] != null) {
          String role = user['role']; // احصل على الدور من البيانات
          if (role == "User") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => UserDashboard(
                        userId: user['userId'],
                        token: '',
                      )),
            );
          } else if (role == "Driver") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => DriverDashboard(
                        userId: user['userId'],
                        token: '',
                      )),
            );
          } else if (role == "Admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => AdminDashboard(
                        userId: user['userId'],
                        token: 'token',
                      )),
            );
          } else if (role == "Manager") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => OfficeManagerPage(
                          officeId: '',
                        )));
          } else {
            showError("Invalid role received!");
          }
        } else {
          showError("Invalid data received from server.");
        }
      } catch (e) {
        showError("Error parsing response data.");
      }
    } else {
      showError("Login failed! Please check your credentials.");
    }
    return;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String signInText = AppLocalizations.of(context).translate('sign_in');
    String emailHintText =
        AppLocalizations.of(context).translate('email_or_phone');
    String passwordHintText =
        AppLocalizations.of(context).translate('enter_password');
    String forgetPasswordText =
        AppLocalizations.of(context).translate('forget_password');
    String signUpText =
        AppLocalizations.of(context).translate('dont_have_account');
    String signUpLinkText = AppLocalizations.of(context).translate('sign_up');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600;
          return Center(
            child: Container(
              width: isWeb ? 400 : double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(signInText,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: emailHintText,
                    controller: emailController,
                    width: double.infinity,
                    hintTextColor: theme.hintColor,
                    textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: passwordHintText,
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
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen())),
                      child: Text(forgetPasswordText,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomButton(
                    text: isLoading ? "Loading..." : signInText,
                    width: double.infinity,
                    onPressed: isLoading ? null : () => signIn(context),
                  ),
                  SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SocialButton(
                        assetPath: "assets/image-removebg-preview4.png"),
                    SizedBox(width: 15),
                    SocialButton(
                        assetPath: "assets/image-removebg-preview4.png"),
                    SizedBox(width: 15),
                    SocialButton(
                        assetPath: "assets/image-removebg-preview5.png"),
                  ]),
                  Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignUpScreen())),
                      child: Text.rich(
                        TextSpan(
                          text: signUpText,
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                          children: [
                            TextSpan(
                              text: signUpLinkText,
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold),
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
