import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  List<Map<String, String>> onboardingData = [
    {"image": "assets/image-removebg-preview1.png", "title": "Anywhere you are", "desc": "Easily book your ride from anywhere"},
    {"image": "assets/image-removebg-preview2.png", "title": "At anytime", "desc": "Request a ride 24/7 with ease"},
    {"image": "assets/image-removebg-preview3.png", "title": "Book your car", "desc": "Choose the best car for your journey"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          return OnboardingPage(
            image: onboardingData[index]['image']!,
            title: onboardingData[index]['title']!,
            description: onboardingData[index]['desc']!,
          );
        },
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
          onPressed: () {
            if (_currentIndex == onboardingData.length - 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
            } else {
              _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
            }
          },
          child: Text(_currentIndex == onboardingData.length - 1 ? "Get Started" : "Next"),
        ),
      ),
    );
  }
}
