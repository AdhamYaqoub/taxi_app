import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCarType;
  String? selectedPaymentMethod = "نقدي";
  bool hasActiveRide = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🚖 طلب رحلة جديدة", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // إدخال الموقع والوجهة
          _buildLocationInput("📍 موقعك الحالي", "أدخل موقعك"),
          const SizedBox(height: 10),
          _buildLocationInput("🎯 الوجهة", "إلى أين؟"),

          const SizedBox(height: 15),

          // اختيار نوع السيارة
          _buildCarTypeSelector(),

          const SizedBox(height: 10),

          // تقدير الأجرة + اختيار طريقة الدفع
          _buildEstimateFareAndPayment(),

          const SizedBox(height: 20),

          // زر طلب الرحلة
          _buildRequestRideButton(),

          const SizedBox(height: 20),

          // إذا كان هناك رحلة جارية، أظهر معلوماتها
          hasActiveRide ? _buildActiveRideInfo() : const SizedBox(),
        ],
      ),
    );
  }

  // 🏠 إدخال الموقع والوجهة
  Widget _buildLocationInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // 🚗 اختيار نوع السيارة
  Widget _buildCarTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🚗 اختر نوع السيارة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCarTypeOption("🚕 اقتصادي"),
            _buildCarTypeOption("🚙 فخم"),
            _buildCarTypeOption("🚌 عائلي"),
          ],
        ),
      ],
    );
  }

  Widget _buildCarTypeOption(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCarType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedCarType == type ? Colors.yellow.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 💰 تقدير الأجرة + اختيار الدفع
  Widget _buildEstimateFareAndPayment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // تقدير الأجرة
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("💰 تقدير الأجرة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text("15-20 شيكل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),

        // اختيار طريقة الدفع
        DropdownButton<String>(
          value: selectedPaymentMethod,
          items: ["نقدي", "بطاقة", "Smile to Pay"].map((String method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedPaymentMethod = newValue;
            });
          },
        ),
      ],
    );
  }

  // 🚖 زر طلب الرحلة
  Widget _buildRequestRideButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            hasActiveRide = true; // تفعيل حالة الرحلة الجارية
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: const Text("🚖 طلب رحلة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  // 📍 معلومات الرحلة الجارية
  Widget _buildActiveRideInfo() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🚖 رحلتك جارية!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),

            // معلومات السائق
            Row(
              children: [
                const CircleAvatar(backgroundImage: AssetImage("assets/driver.png"), radius: 25),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("👨‍✈️ السائق: محمد أحمد", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("🚗 السيارة: تويوتا كورولا - بيضاء", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // تقدير الوقت المتبقي
            const Text("⏳ الوقت المتوقع للوصول: 5 دقائق", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            // زر الطوارئ
            ElevatedButton.icon(
              onPressed: () {
                // تنفيذ إجراء الطوارئ
              },
              icon: const Icon(LucideIcons.alertCircle, color: Colors.red),
              label: const Text("🚨 طوارئ - مشاركة الموقع"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
