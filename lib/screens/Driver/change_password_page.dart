import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChangePasswordPage extends StatefulWidget {
  final int driverId;
  const ChangePasswordPage({super.key, required this.driverId});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final _codeFormKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _newPassController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;

  String _code = '';
  String _newPass = '';

  @override
  void dispose() {
    _codeController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  Future<bool> _sendResetCode() async {
    final url = '${dotenv.env['BASE_URL']}/api/drivers/send-reset-code';
    try {
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{"driverId": ${widget.driverId}}',
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _verifyResetCode(String code) async {
    final url = '${dotenv.env['BASE_URL']}/api/drivers/verify-reset-code';
    try {
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{"driverId": ${widget.driverId}, "code": "$code"}',
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _resetPassword(String newPassword) async {
    final url = '${dotenv.env['BASE_URL']}/api/drivers/reset-password';
    try {
      final resp = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body:
            '{"driverId": ${widget.driverId}, "newPassword": "$newPassword"}',
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _handleSendCode() async {
    setState(() => _isLoading = true);
    final ok = await _sendResetCode();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _codeSent = ok;
    });
    if (!ok) _showSnack(AppLocalizations.of(context).translate('code_send_failed'));
  }

  Future<void> _handleVerifyCode() async {
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;
    _codeFormKey.currentState!.save();

    setState(() => _isLoading = true);
    final ok = await _verifyResetCode(_code);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _codeVerified = ok;
    });
    if (!ok) _showSnack(AppLocalizations.of(context).translate('code_invalid'));
  }

  Future<void> _handleResetPassword() async {
    if (!(_passFormKey.currentState?.validate() ?? false)) return;
    _passFormKey.currentState!.save();

    setState(() => _isLoading = true);
    final ok = await _resetPassword(_newPass);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      _showSnack(AppLocalizations.of(context).translate('password_changed'));
      Navigator.of(context).pop();
    } else {
      _showSnack(AppLocalizations.of(context).translate('password_change_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(local.translate('change_password'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_codeSent
                // STEP 1: زر إرسال الكود
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(local.translate('enter_email_to_send_code')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleSendCode,
                        child: Text(local.translate('send_code')),
                      ),
                    ],
                  )
                : !_codeVerified
                    // STEP 2: إدخال كود التحقق
                    ? Form(
                        key: _codeFormKey,
                        child: Column(
                          children: [
                            Text(local.translate('enter_verification_code')),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: InputDecoration(
                                labelText: local.translate('verification_code'),
                                counterText: '',
                              ),
                              validator: (v) {
                                if (v == null || v.length != 6) {
                                  return local.translate('code_must_6_digits');
                                }
                                return null;
                              },
                              onSaved: (v) => _code = v ?? '',
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _handleVerifyCode,
                              child: Text(local.translate('verify')),
                            ),
                          ],
                        ),
                      )
                    // STEP 3: إدخال كلمة المرور الجديدة
                    : Form(
                        key: _passFormKey,
                        child: Column(
                          children: [
                            Text(local.translate('set_new_password')),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _newPassController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: local.translate('new_password')),
                              validator: (v) {
                                if (v == null || v.length < 6) {
                                  return local.translate('password_min_length');
                                }
                                return null;
                              },
                              onSaved: (v) => _newPass = v ?? '',
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _handleResetPassword,
                              child: Text(local.translate('submit')),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
