import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("📞 مركز الدعم والطوارئ"),
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // ضبط العرض للويب
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📞 مركز الدعم والطوارئ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // 🚑 زر الطوارئ
              _buildEmergencyButton(),

              const SizedBox(height: 20),

              // 📩 خيارات التواصل مع الدعم
              _buildSupportOptions(),

              const SizedBox(height: 20),

              // ❓ الأسئلة الشائعة (FAQ)
              _buildFAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 🚨 زر الطوارئ (SOS)
  Widget _buildEmergencyButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // تنفيذ إجراء الطوارئ مثل إرسال الموقع
        },
        icon: const Icon(LucideIcons.alertCircle, color: Colors.white),
        label: const Text("🚨 طوارئ - إرسال الموقع الآن"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  // ☎️ خيارات التواصل مع الدعم الفني
  Widget _buildSupportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("☎️ كيف يمكننا مساعدتك؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(LucideIcons.phoneCall, color: Colors.green),
          title: const Text("📞 الاتصال بالدعم الفني"),
          onTap: () {
            // تنفيذ الاتصال بالدعم الفني
          },
        ),
        ListTile(
          leading: const Icon(LucideIcons.mail, color: Colors.blue),
          title: const Text("📩 إرسال بريد إلكتروني"),
          onTap: () {
            // تنفيذ إرسال بريد إلكتروني
          },
        ),
        ListTile(
          leading: const Icon(LucideIcons.messageCircle, color: Colors.orange),
          title: const Text("💬 الدردشة مع الدعم"),
          onTap: () {
            // فتح نافذة الدردشة
          },
        ),
      ],
    );
  }

  // ❓ قسم الأسئلة الشائعة (FAQ)
  Widget _buildFAQSection() {
    return ExpansionTile(
      title: const Text("❓ الأسئلة الشائعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        _buildFAQItem("كيف يمكنني إلغاء رحلة؟", "يمكنك إلغاء الرحلة من خلال التطبيق قبل وصول السائق."),
        _buildFAQItem("ماذا أفعل إذا نسيت شيئًا في السيارة؟", "يمكنك التواصل مع الدعم الفني لمساعدتك في استعادة أغراضك."),
        _buildFAQItem("هل يمكنني طلب رحلة مجدولة؟", "نعم، يمكنك تحديد موعد مستقبلي لرحلتك."),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ListTile(
      title: Text("🔹 $question", style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(answer),
    );
  }
}
