import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'Arabic';

  String get selectedLanguage => _selectedLanguage;

  void toggleLanguage() {
    _selectedLanguage = _selectedLanguage == 'Arabic' ? 'English' : 'Arabic';
    notifyListeners();
  }
}
