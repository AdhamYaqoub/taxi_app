import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("💳 إدارة الدفع - 'Smile to Pay'"),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              "طريقة الدفع: 'Smile to Pay'",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // Description of the feature
            Text(
              "استخدم تقنية التعرف على الوجه لدفع ثمن رحلاتك ببساطة وأمان.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // Instructions
            Text(
              "الخطوات:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("1. اختر 'Smile to Pay' كطريقة دفع.", style: TextStyle(fontSize: 14)),
            Text("2. افتح كاميرا الهاتف وتأكد من الابتسامة.", style: TextStyle(fontSize: 14)),
            Text("3. سيتم إتمام الدفع تلقائيًا بمجرد اكتشاف الابتسامة.", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),

            // Payment Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement the functionality for 'Smile to Pay'
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("استخدام 'Smile to Pay'"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Handle Web and Mobile Responsiveness
            if (isWeb) ...[
              // Web-specific adjustments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaymentOptionCard('طريقة الدفع النقدي', 'القيام بالدفع نقدًا بعد إتمام الرحلة', Icons.attach_money),
                  _buildPaymentOptionCard('الدفع بالبطاقة', 'الدفع باستخدام بطاقة الائتمان/الخصم', Icons.credit_card),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.yellow.shade700),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Handle the payment option action
              },
              child: const Text("اختيار الطريقة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
