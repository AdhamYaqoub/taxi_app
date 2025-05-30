import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/screens/components/custom_button.dart';
import 'package:taxi_app/screens/components/custom_text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:taxi_app/screens/signin_screen.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DriverSignUpScreen extends StatefulWidget {
  const DriverSignUpScreen({super.key});

  @override
  _DriverSignUpScreenState createState() => _DriverSignUpScreenState();
}

class _DriverSignUpScreenState extends State<DriverSignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();
  final TextEditingController taxiOfficeNumberController =
      TextEditingController(); // حقل جديد لرقم مكتب التاكسي

  String selectedCountryCode = '+1';
  String selectedCountryFlag = '🇺🇸';
  String? selectedGender = 'Male';
  // String? selectedTaxiOffice; // تم الاستغناء عنه
  bool isPrivacyAccepted = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  DateTime? selectedLicenseExpiry;
  bool isLoading = false; // حالة التحميل للزر

  // List<String> taxiOffices = ['Office 1', 'Office 2', 'Office 3']; // تم الاستغناء عنها

  // دالة لعرض رسائل SnackBar
  void showSnackBarMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _selectLicenseExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLicenseExpiry ??
          DateTime.now(), // استخدم التاريخ المحدد مسبقًا
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // لون الثيم الأساسي
              onPrimary: Colors.white, // لون النص على اللون الأساسي
              surface: Theme.of(context).cardColor, // لون خلفية التقويم
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ??
                  Colors.black, // لون النص على الخلفية
            ),
            dialogBackgroundColor:
                Theme.of(context).cardColor, // لون خلفية الحوار
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedLicenseExpiry = picked;
        licenseExpiryController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> signUp() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    // التحقق من الحقول الأساسية
    if (fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        licenseNumberController.text.isEmpty ||
        licenseExpiryController.text.isEmpty ||
        plateNumberController.text.isEmpty ||
        carModelController.text.isEmpty ||
        carColorController.text.isEmpty ||
        taxiOfficeNumberController.text.isEmpty) {
      // التحقق من حقل رقم المكتب الجديد
      showSnackBarMessage(
          AppLocalizations.of(context).translate('fill_all_fields'),
          isError: true);
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showSnackBarMessage(
          AppLocalizations.of(context).translate('passwords_not_match'),
          isError: true);
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    if (!isPrivacyAccepted) {
      showSnackBarMessage(
          AppLocalizations.of(context).translate('accept_privacy_policy'),
          isError: true);
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      if (mounted) {
        showSnackBarMessage(
            AppLocalizations.of(context).translate('base_url_not_configured'),
            isError: true);
      }
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    final String url = '$baseUrl/api/users/signup';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullNameController.text,
          'phone': selectedCountryCode + phoneController.text, // دمج رمز الدولة
          'email': emailController.text,
          'password': passwordController.text,
          'confirmPassword': confirmPasswordController.text,
          'role': 'Driver',
          'gender': selectedGender,
          'officeIdentifier':
              taxiOfficeNumberController.text, // استخدام قيمة الحقل النصي
          'carModel': carModelController.text,
          'carPlateNumber': plateNumberController.text,
          'carColor': carColorController.text,
          'licenseNumber': licenseNumberController.text,
          'licenseExpiry': licenseExpiryController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        showSnackBarMessage(AppLocalizations.of(context)
            .translate('account_created_success_driver')); // رسالة خاصة بالسائق
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        final errorBody = json.decode(response.body);
        showSnackBarMessage(
          errorBody['message'] ??
              AppLocalizations.of(context).translate('error_creating_account'),
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBarMessage(
          "${AppLocalizations.of(context).translate('network_error')}: ${e.toString()}",
          isError: true);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    Color hintColor = theme.hintColor;
    Color cardColor = theme.cardColor;
    Color primaryColor = theme.primaryColor;
    Color accentColor = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        foregroundColor: theme.appBarTheme.foregroundColor ??
            Colors.white, // لون أيقونات ونصوص الـ AppBar
        elevation: 0,
        title: Text(localizations.translate('driver_sign_up')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading
              ? null
              : () => Navigator.pop(context), // تعطيل الزر أثناء التحميل
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? constraints.maxWidth * 0.15 : 20,
                vertical: isLargeScreen ? 30 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen
                      ? 800
                      : double
                          .infinity, // عرض أقصى أكبر قليلاً للسائقين بسبب الحقول الإضافية
                ),
                child: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 30 : 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.translate('driver_sign_up'),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 32 : 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 30 : 20),

                      // القسم 1: معلومات أساسية
                      Align(
                        alignment: localizations.isRTL
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          localizations.translate('basic_info'),
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 15),

                      CustomTextField(
                        hintText: localizations.translate('full_name'),
                        controller: fullNameController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    selectedCountryCode =
                                        "+${country.phoneCode}";
                                    selectedCountryFlag = country.flagEmoji;
                                  });
                                },
                                countryFilter: [
                                  'US',
                                  'EG',
                                  'SA',
                                  'JO',
                                  'AE',
                                  'QA',
                                  'KW',
                                  'PS', // فلسطين
                                  'IL'
                                ],
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor ??
                                    Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: hintColor.withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(selectedCountryFlag,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(selectedCountryCode,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor)),
                                  const Icon(Icons.arrow_drop_down,
                                      size: 20, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              hintText: localizations.translate('phone_number'),
                              controller: phoneController,
                              width: double.infinity,
                              hintTextColor: hintColor,
                              textColor: textColor,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('email'),
                        controller: emailController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('password'),
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        suffixIcon: isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.lock,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('confirm_password'),
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.lock,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: hintColor.withOpacity(0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGender,
                            dropdownColor: cardColor,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Icon(Icons.arrow_drop_down, color: textColor),
                            style: TextStyle(color: textColor, fontSize: 16),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGender = newValue;
                              });
                            },
                            items: <String>['Male', 'Female']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      value == 'Male'
                                          ? Icons.male_outlined
                                          : Icons.female_outlined,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(localizations
                                        .translate(value.toLowerCase())),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: isLargeScreen ? 30 : 20),

                      // القسم 2: معلومات السائق والمركبة
                      Align(
                        alignment: localizations.isRTL
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          localizations.translate('driver_vehicle_info'),
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 15),

                      CustomTextField(
                        hintText: localizations.translate('license_number'),
                        controller: licenseNumberController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.credit_card,
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _selectLicenseExpiry(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: localizations.translate('license_expiry'),
                            controller: licenseExpiryController,
                            suffixIcon: Icons.calendar_today,
                            width: double.infinity,
                            hintTextColor: hintColor,
                            textColor: textColor,
                            prefixIcon: Icons.date_range,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('plate_number'),
                        controller: plateNumberController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.numbers,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('car_model'),
                        controller: carModelController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.directions_car,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: localizations.translate('car_color'),
                        controller: carColorController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        prefixIcon: Icons.color_lens,
                      ),
                      const SizedBox(height: 15),

                      // حقل رقم مكتب التاكسي (بدلاً من القائمة المنسدلة)
                      CustomTextField(
                        hintText: localizations.translate('taxi_office_number'),
                        controller: taxiOfficeNumberController,
                        width: double.infinity,
                        hintTextColor: hintColor,
                        textColor: textColor,
                        keyboardType: TextInputType.number, // لأنه رقم
                        prefixIcon: Icons.business, // أيقونة مناسبة للمكتب
                      ),
                      const SizedBox(height: 20),

                      // سياسة الخصوصية
                      Row(
                        children: [
                          Checkbox(
                            value: isPrivacyAccepted,
                            onChanged: isLoading
                                ? null
                                : (bool? value) {
                                    // تعطيل الـ checkbox أثناء التحميل
                                    setState(() {
                                      isPrivacyAccepted = value!;
                                    });
                                  },
                            activeColor: primaryColor,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isLoading)
                                  return; // تعطيل النقر أثناء التحميل
                                showSnackBarMessage(localizations
                                    .translate('privacy_policy_clicked'));
                                // يمكنك إضافة منطق لفتح سياسة الخصوصية هنا
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: localizations.translate('i_agree_to'),
                                  style:
                                      TextStyle(color: textColor, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: localizations
                                          .translate('privacy_policy_link'),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: isLoading
                            ? localizations.translate('loading')
                            : localizations.translate('sign_up'),
                        width: double.infinity,
                        onPressed:
                            isLoading || !isPrivacyAccepted ? null : signUp,
                        buttonColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // تعطيل الزر أثناء التحميل
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen()),
                                  );
                                },
                          child: Text.rich(
                            TextSpan(
                              text:
                                  "${localizations.translate('already_have_account')} ",
                              style: TextStyle(color: textColor),
                              children: [
                                TextSpan(
                                  text: localizations.translate('sign_in'),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 0),
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
