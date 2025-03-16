import 'package:flutter/material.dart';
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MapScreen(),
//     );
//   }
// }
class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600; // إذا كانت الشاشة أعرض من 600 بيكسل، نعتبرها ويب

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Our App!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We are committed to providing the best service to our customers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Meet Our Team',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 20),
                  
                  // ✅ تغيير التصميم بناءً على حجم الشاشة
                  isWideScreen
                      ? Row( // تصميم أفقي عند العرض الواسع
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: TeamMemberCard(
                              name: 'Adham Yaqoub',
                              role: 'CEO & Founder',
                              phone: '+972 59 4348 312',
                              email: 'amamry2024.2002@gmail.com',
                              imageUrl: 'https://via.placeholder.com/150',
                            )),
                            SizedBox(width: 20),
                            Expanded(child: TeamMemberCard(
                              name: 'Yazan Edaily',
                              role: 'CTO',
                              phone: '+1 987 654 321',
                              email: 'yazan@gmail.com',
                              imageUrl: 'https://via.placeholder.com/150',
                            )),
                          ],
                        )
                      : Column( // تصميم رأسي عند الشاشة الصغيرة
                          children: [
                            TeamMemberCard(
                              name: 'Adham Yaqoub',
                              role: 'CEO & Founder',
                              phone: '+972 59 4348 312',
                              email: 'amamry2024.2002@gmail.com',
                              imageUrl: 'https://via.placeholder.com/150',
                            ),
                            TeamMemberCard(
                              name: 'Yazan Edaily',
                              role: 'CTO',
                              phone: '+1 987 654 321',
                              email: 'yazan@gmail.com',
                              imageUrl: 'https://via.placeholder.com/150',
                            ),
                          ],
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

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final String email;
  final String imageUrl;

  TeamMemberCard({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Text(role, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.deepPurple),
                      SizedBox(width: 5),
                      Text(phone, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.deepPurple),
                      SizedBox(width: 5),
                      Text(email, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
