import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/driver.dart';
import 'package:intl/intl.dart';

class DriverDetailPageWeb extends StatelessWidget {
  final Driver driver;

  const DriverDetailPageWeb({super.key, required this.driver});

  // دالة مساعدة لإنشاء عنوان قسم
  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    // تم تغييرها لاستقبال مفتاح الترجمة
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
        child: Text(
          AppLocalizations.of(context).translate(titleKey), // استخدام الترجمة
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء صف تفصيلي (Label: Value)
  Widget _buildDetailRow(BuildContext context, String labelKey, String value) {
    // تم تغييرها لاستقبال مفتاح الترجمة و context
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    print(
        "DriverDetailPageWeb: Building driver detail page for ${driver.profileImageUrl}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
            driver.fullName), // اسم السائق ديناميكي، لا يحتاج ترجمة مباشرة هنا
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
                width: MediaQuery.of(context).size.width > 900
                    ? 800
                    : screenSize.width * 0.7,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(driver
                                    .profileImageUrl ??
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrUfiySJr8Org5W-oE2v3_i7VqufglYtSdqw&s'),
                            backgroundColor: Colors.grey[200],
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading image: $exception');
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            driver.fullName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // **معلومات شخصية**
                    _buildSectionTitle(context,
                        'driver_detail_personal_info_title'), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'driver_detail_phone_label',
                        driver.phone), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'driver_detail_email_label',
                        driver.email), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                      context,
                      'driver_detail_rating_label', // استخدام مفتاح الترجمة
                      "${driver.rating.toStringAsFixed(1)} ★ (${driver.numberOfRatings} ${AppLocalizations.of(context).translate('driver_detail_ratings_suffix')})", // استخدام الترجمة
                    ),
                    _buildDetailRow(context, 'driver_detail_earnings_label',
                        "${driver.earnings.toStringAsFixed(2)}"), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                      context,
                      'driver_detail_availability_status_label', // استخدام مفتاح الترجمة
                      driver.isAvailable
                          ? AppLocalizations.of(context).translate(
                              'driver_detail_status_available') // استخدام الترجمة
                          : AppLocalizations.of(context).translate(
                              'driver_detail_status_unavailable'), // استخدام الترجمة
                    ),
                    _buildDetailRow(
                        context,
                        'driver_detail_joined_date_label', // استخدام مفتاح الترجمة
                        DateFormat('dd/MM/yyyy').format(driver.joinedAt)),

                    // **معلومات السيارة**
                    _buildSectionTitle(context,
                        'driver_detail_car_info_title'), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'driver_detail_car_model_label',
                        driver.carModel), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'driver_detail_car_color_label',
                        driver.carColor), // استخدام مفتاح الترجمة
                    _buildDetailRow(context, 'driver_detail_car_plate_label',
                        driver.carPlateNumber), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                        context,
                        'driver_detail_car_year_label', // استخدام مفتاح الترجمة
                        driver.carYear?.toString() ??
                            AppLocalizations.of(context).translate(
                                'driver_detail_car_year_not_specified')), // استخدام الترجمة

                    // **معلومات الرخصة**
                    _buildSectionTitle(context,
                        'driver_detail_license_info_title'), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                        context,
                        'driver_detail_license_number_label',
                        driver.licenseNumber), // استخدام مفتاح الترجمة
                    _buildDetailRow(
                      context,
                      'driver_detail_license_expiry_label', // استخدام مفتاح الترجمة
                      DateFormat('dd/MM/yyyy').format(driver.licenseExpiry),
                    ),

                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${AppLocalizations.of(context).translate('driver_detail_call_driver_snackbar_prefix')} ${driver.fullName} ${AppLocalizations.of(context).translate('driver_detail_call_driver_snackbar_suffix')} ${driver.phone}')), // استخدام الترجمة
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: Text(AppLocalizations.of(context).translate(
                            'driver_detail_call_driver_button')), // استخدام الترجمة
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          elevation: 4,
                        ),
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
