import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/screens/components/custom_button.dart';
import 'package:taxi_app/screens/components/custom_text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:taxi_app/screens/ecxel.dart';
import 'package:taxi_app/screens/signin_screen.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;

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
  String? selectedGender = 'Male';
  String? selectedRole = 'User';
  String? selectedTaxiOffice;
  bool isPrivacyAccepted = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  List<String> taxiOffices = ['Office 1', 'Office 2', 'Office 3'];
Future<void> signUp() async {
  final String url = '${dotenv.env['BASE_URL']}/api/users/signup';
    
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fullName': fullNameController.text,
      'phone': phoneController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
      'role': selectedRole,
      'gender': selectedGender,
      'taxiOffice': selectedRole == 'Driver' ? selectedTaxiOffice : null,
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: CustomAppBar(),
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
                      const SizedBox(height: 40),
                      CustomTextField(
                        hintText: localizations.translate('full_name'),
                        controller: fullNameController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 15),
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
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(selectedCountryFlag, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Text(selectedCountryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      CustomTextField(
                        hintText: localizations.translate('phone_number'),
                        controller: phoneController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: localizations.translate('email'),
                        controller: emailController,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: localizations.translate('password'),
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      CustomTextField(
                        hintText: localizations.translate('confirm_password'),
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        width: double.infinity,
                        hintTextColor: Colors.grey,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 15),
                      DropdownButton<String>(
                        value: selectedRole,
                        dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue;
                            if (selectedRole == 'User') {
                              selectedTaxiOffice = null;
                            }
                          });
                        },
                        items: <String>['User', 'Driver']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(localizations.translate(value.toLowerCase()), style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                        hint: Text(localizations.translate('select_role'), style: TextStyle(color: textColor)),
                      ),
                      const SizedBox(height: 15),
                      if (selectedRole == 'Driver')
                        DropdownButton<String>(
                          value: selectedTaxiOffice,
                          dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTaxiOffice = newValue;
                            });
                          },
                          items: taxiOffices
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: textColor)),
                            );
                          }).toList(),
                          hint: Text(localizations.translate('select_taxi_office'), style: TextStyle(color: textColor)),
                        ),
                      const SizedBox(height: 15),
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
                            child: Text(localizations.translate(value.toLowerCase()), style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                        hint: Text(localizations.translate('select_gender'), style: TextStyle(color: textColor)),
                      ),
                      const SizedBox(height: 15),
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
                              localizations.translate('privacy_policy'),
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: localizations.translate('sign_up'),
                        width: double.infinity,
                        onPressed: signUp,
                      ),
                      const SizedBox(height: 20),
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
                              text: "${localizations.translate('already_have_account')} ",
                              style: TextStyle(color: textColor),
                              children: [
                                TextSpan(
                                  text: localizations.translate('sign_in'),
                                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
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
