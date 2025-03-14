import 'package:flutter/material.dart';
import 'package:taxi_app/screens/components/custom_button.dart';
import 'package:taxi_app/screens/components/custom_text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:taxi_app/screens/signin_screen.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String selectedCountryCode = '+1';
  String selectedCountryFlag = '🇺🇸';
  String selectedLanguage = 'en';
  bool isPrivacyAccepted = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: CustomAppBar(selectedLanguage: selectedLanguage, hiddenButtons: ['signup']),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 50 : 20),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 600 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 40),

                      CustomTextField(
                        hintText: 'Full Name',
                        controller: fullNameController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      SizedBox(height: 15),

                      InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountryCode = "+${country.phoneCode}";
                                selectedCountryFlag = country.flagEmoji;
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(selectedCountryFlag, style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Text(selectedCountryCode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Spacer(),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      CustomTextField(
                        hintText: 'Phone Number',
                        controller: phoneController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: 'Email',
                        controller: emailController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: 'Enter Your Password',
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: 'Confirm Password',
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),

                      CustomTextField(
                        hintText: 'Confirm Password',
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      SizedBox(height: 15),

                      DropdownButton<String>(
                        value: selectedGender,
                        dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                        items: <String>['Male', 'Female']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                        hint: Text("Select Gender", style: TextStyle(color: textColor)),
                      ),
                      SizedBox(height: 15),

                      Row(
                        children: [
                          Checkbox(
                            value: isPrivacyAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                isPrivacyAccepted = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "I agree to the Privacy Policy and Terms & Conditions",
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      CustomButton(
                        text: 'Sign Up',
                        width: double.infinity,
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignInScreen()),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: textColor),
                              children: [
                                TextSpan(
                                  text: "Sign In",
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
              ),
            ),
          );
        },
      ),
    );
  }
}
