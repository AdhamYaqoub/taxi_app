import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // استيراد dotenv
import 'package:taxi_app/language/localization.dart'; // مسار ملف AppLocalizations الخاص بك
import 'package:taxi_app/widgets/CustomAppBar.dart'; // تأكد من وجود هذا الـ widget

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // حالة تحميل لتشغيل مؤشر التحميل

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    final local = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return; // توقف إذا كان هناك أخطاء في التحقق من صحة النموذج
    }

    setState(() {
      _isLoading = true; // ابدأ التحميل
    });

    try {
      final String? baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في تهيئة عنوان الـ API.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/users/forgot-password'), // نقطة نهاية الـ API لنسيان كلمة المرور
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim()
        }), // trim لإزالة المسافات البيضاء
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ??
                  local.translate('reset_link_sent_success'))),
        );
        // يمكنك مسح حقل البريد الإلكتروني بعد النجاح
        _emailController.clear();
        // أو يمكنك العودة للصفحة السابقة
        // Navigator.pop(context);
      } else {
        // التعامل مع الأخطاء من الـ Backend
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorData['message'] ??
                  local.translate('something_went_wrong'))),
        );
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة (مثل عدم الاتصال بالإنترنت)
      print('Error sending reset link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.translate('something_went_wrong'))),
      );
    } finally {
      setState(() {
        _isLoading = false; // إنهاء التحميل بغض النظر عن النتيجة
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(
                maxWidth: 500), // لتحديد عرض أقصى للشاشات الكبيرة
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // لجعل العناصر تمتد عرضياً
                    children: [
                      Text(
                        local.translate('forgot_password_title'),
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).primaryColorDark // لون داكن
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        local.translate('forgot_password_instruction'),
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: local.translate('email_address'),
                          hintText: 'example@email.com',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return local.translate('email_empty_validation');
                          }
                          // Regular expression for email validation
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return local.translate('email_invalid_validation');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _sendResetLink, // تعطيل الزر أثناء التحميل
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor, // اللون الأصفر
                          foregroundColor: Colors.black87, // لون النص
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black87,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                local.translate('send_reset_link_button'),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
