import 'package:flutter/material.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("🎁 العروض والخصومات"),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              "العروض الحالية",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // Example of available offers
            _buildOfferCard(
                "عرض 10% على الرحلات لأول مرة", "يوم الجمعة فقط", Colors.green.shade600),
            const SizedBox(height: 16),
            _buildOfferCard(
                "خصم 20% للرحلات ضمن نفس المنطقة", "ينتهي يوم الاثنين", Colors.blue.shade600),
            const SizedBox(height: 16),

            // Handle Web and Mobile Responsiveness
            if (isWeb) ...[
              // Web-specific adjustments
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildOfferCard("عرض 10% على الرحلات لأول مرة", "يوم الجمعة فقط", Colors.green.shade600)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildOfferCard("خصم 20% للرحلات ضمن نفس المنطقة", "ينتهي يوم الاثنين", Colors.blue.shade600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String offerDescription, String validity, Color offerColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offerDescription, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("صلاحية العرض: $validity", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: offerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "خصم مميز",
                style: TextStyle(color: offerColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onPressed: () {
                    // Navigate to offer details or take further actions
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
