import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/client.dart';

class ClientDetailPageWeb extends StatelessWidget {
  final Client client;

  const ClientDetailPageWeb({super.key, required this.client});

  // لا تزال هذه الدالة موجودة ولكن يمكن تغييرها لاستقبال مفتاح الترجمة بدلاً من النص المباشر
  Widget _buildDetailRow(BuildContext context, String labelKey, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "${AppLocalizations.of(context).translate(labelKey)}:", // استخدام الترجمة
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // يمكن إضافة دالة عنوان قسم إذا أردت تقسيم المحتوى مثل صفحة السائق
  // Widget _buildSectionTitle(BuildContext context, String titleKey) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
  //       child: Text(
  //         AppLocalizations.of(context).translate(titleKey),
  //         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: Theme.of(context).colorScheme.primary,
  //             ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate('client_detail_page_title_prefix')), // عنوان ثابت
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                // تحديد عرض الـ Card ليكون متجاوبًا ولكنه ليس كبيراً جداً
                width: MediaQuery.of(context).size.width > 900
                    ? 800 // أقصى عرض 800 بكسل للشاشات الكبيرة جداً
                    : screenSize.width * 0.7, // 70% من عرض الشاشة الافتراضي
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // تركها Center هنا كما في الكود الأصلي
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(client.profileImageUrl ??
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrUfiySJr8Org5W-oE2v3_i7VqufglYtSdqw&s'),
                      backgroundColor: Colors.grey[200],
                      onBackgroundImageError: (exception, stackTrace) {
                        print(
                            'Error loading client image: $exception'); // سجل خطأ تحميل الصورة
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      client.fullName, // اسم العميل ديناميكي
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // يمكن إضافة _buildSectionTitle هنا إذا أردت فصل المحتوى
                    // _buildSectionTitle(context, 'client_detail_personal_info_title'),

                    _buildDetailRow(context, 'client_detail_phone_label',
                        client.phone), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'client_detail_email_label',
                        client.email), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                        context,
                        'client_detail_total_spending_label',
                        "${client.totalSpending.toStringAsFixed(2)}"), // استخدام مفتاح الترجمة مع تنسيق
                    _buildDetailRow(context, 'client_detail_trips_number_label',
                        "${client.tripsNumber}"), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                      context,
                      'client_detail_availability_status_label', // استخدام مفتاح الترجمة
                      client.isAvailable
                          ? AppLocalizations.of(context).translate(
                              'client_detail_status_available') // استخدام الترجمة
                          : AppLocalizations.of(context).translate(
                              'client_detail_status_unavailable'), // استخدام الترجمة
                    ),
                    _buildDetailRow(
                        context,
                        'client_detail_type_label', // استخدام مفتاح الترجمة
                        AppLocalizations.of(context).translate(
                            'client_detail_type_client')), // استخدام الترجمة للنوع
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // تنفيذ الإجراء مثل الاتصال بالعميل
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${AppLocalizations.of(context).translate('client_detail_call_client_snackbar_prefix')} ${client.fullName} ${AppLocalizations.of(context).translate('client_detail_call_client_snackbar_suffix')} ${client.phone}')), // استخدام الترجمة
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: Text(AppLocalizations.of(context).translate(
                          'client_detail_call_client_button')), // استخدام الترجمة
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16), // زيادة حجم الزر قليلاً
                        textStyle: const TextStyle(fontSize: 18),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
