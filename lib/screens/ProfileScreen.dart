import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoggedIn = false;
  String selectedLanguage = 'en'; // Define selectedLanguage with a default value

  Future<void> _loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'], // طلب إذن الاسم والصورة والبريد
    );

    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      setState(() {
        _isLoggedIn = true;
        _userData = userData;
      });
    } else {
      print("فشل تسجيل الدخول: ${result.message}");
    }
  }

  Future<void> _logout() async {
    await FacebookAuth.instance.logOut();
    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(selectedLanguage: selectedLanguage, hiddenButtons: ['profile']),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _isLoggedIn
                    ? NetworkImage(_userData!["picture"]["data"]["url"])
                    : null,
                child: _isLoggedIn ? null : Icon(Icons.person, size: 50),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: "Full Name"),
              controller: TextEditingController(
                  text: _isLoggedIn ? _userData!["name"] : ""),
            ),
            SizedBox(height: 10),
            _isLoggedIn
                ? ElevatedButton(
                    onPressed: _logout,
                    child: Text("Logout from Facebook"),
                  )
                : ElevatedButton(
                    onPressed: _loginWithFacebook,
                    child: Text("Login with Facebook"),
                  ),
          ],
        ),
      ),
    );
  }
}
