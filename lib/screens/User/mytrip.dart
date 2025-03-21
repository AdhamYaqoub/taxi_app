import 'package:flutter/material.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("📍 قائمة الرحلات السابقة والجارية"),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              "الرحلات الجارية",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // Example of ongoing trips
            _buildTripCard("رحلة إلى منطقة X", "12:30 PM", "قيد التنفيذ", Colors.orange),
            const SizedBox(height: 16),
            _buildTripCard("رحلة إلى منطقة Y", "02:00 PM", "قيد التنفيذ", Colors.orange),
            const SizedBox(height: 16),

            // Title Section
            Text(
              "الرحلات السابقة",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // Example of past trips
            _buildTripCard("رحلة إلى منطقة Z", "10:00 AM", "مكتملة", Colors.green),
            const SizedBox(height: 16),
            _buildTripCard("رحلة إلى منطقة W", "08:30 AM", "مكتملة", Colors.green),
            const SizedBox(height: 16),

            // Handle Web and Mobile Responsiveness
            if (isWeb) ...[
              // Web-specific adjustments
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildTripCard("رحلة إلى منطقة X", "12:30 PM", "قيد التنفيذ", Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTripCard("رحلة إلى منطقة Y", "02:00 PM", "قيد التنفيذ", Colors.orange)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(String destination, String time, String status, Color statusColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(destination, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("الوقت: $time", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onPressed: () {
                    // Navigate to trip details or take further actions
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
