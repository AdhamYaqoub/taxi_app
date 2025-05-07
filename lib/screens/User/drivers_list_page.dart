// screens/User/drivers_list_page.dart (ملف جديد)
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/driver.dart'; // استيراد نموذج السائق
import 'package:taxi_app/services/drivers_api.dart'; // استيراد خدمة API السائقين

class DriversListPage extends StatefulWidget {
  const DriversListPage({super.key});

  @override
  State<DriversListPage> createState() => _DriversListPageState();
}

class _DriversListPageState extends State<DriversListPage> {
  late Future<List<Driver>> _driversFuture;
  bool _isLoading = true; // للتحكم في مؤشر التحميل الأولي

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  // دالة لتحميل أو إعادة تحميل السائقين
  void _loadDrivers() {
    setState(() {
      _isLoading = true; // إظهار المؤشر عند البدء
      _driversFuture = DriversApi.getAvailableDrivers();
    });

    _driversFuture.whenComplete(() {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: isDesktop
          ? null // لا يوجد AppBar لسطح المكتب (يمكن دمجه في تصميم أكبر)
          : AppBar(
              title: Text(
                  local.translate('available_drivers')), // مفتاح ترجمة جديد
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDrivers(); // إعادة التحميل عند السحب
          // ننتظر اكتمال الـ Future الجديد لإنهاء الـ RefreshIndicator
          await _driversFuture;
        },
        // استخدام FutureBuilder لعرض الحالات المختلفة (تحميل، خطأ، بيانات)
        child: FutureBuilder<List<Driver>>(
          future: _driversFuture,
          builder: (context, snapshot) {
            // 1. حالة التحميل (أولي أو أثناء التحديث)
            // نعرض المؤشر الأولي فقط إذا كانت _isLoading صحيحة
            if (_isLoading ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة الخطأ
            if (snapshot.hasError) {
              return _buildErrorWidget(context, local, snapshot.error);
            }

            // 3. حالة النجاح ولكن لا توجد بيانات (قائمة فارغة)
            final drivers = snapshot.data ?? [];
            if (drivers.isEmpty) {
              return _buildEmptyState(context,
                  local.translate('no_available_drivers')); // مفتاح ترجمة جديد
            }

            // 4. حالة النجاح ووجود بيانات
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: 16, // Padding عام
              ),
              // استخدام ListView أو GridView مباشرة هنا
              child: isDesktop
                  ? _buildDriversGrid(context, drivers)
                  : _buildDriversList(context, drivers),
            );
          },
        ),
      ),
    );
  }

  // ودجت لعرض قائمة السائقين على الهاتف
  Widget _buildDriversList(BuildContext context, List<Driver> drivers) {
    return ListView.builder(
      // لا حاجة لـ shrinkWrap أو physics إذا كان هو الـ child المباشر القابل للتمرير
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(context, drivers[index]);
      },
    );
  }

  // ودجت لعرض شبكة السائقين على سطح المكتب
  Widget _buildDriversGrid(BuildContext context, List<Driver> drivers) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor().clamp(2, 3);

    // يمكنك تعديل هذه القيم لتناسب التصميم
    final double itemWidth = MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.width > 1200 ? 4 : 3);
    const double itemHeight = 260; // ارتفاع تقديري للبطاقة

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // استخدم العدد المحسوب
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: itemWidth / itemHeight, // نسبة العرض إلى الارتفاع
      ),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(context, drivers[index]);
      },
    );
  }

  // --- ودجتات مساعدة ---

  // بناء بطاقة عرض السائق
  Widget _buildDriverCard(BuildContext context, Driver driver) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Card(
      margin: EdgeInsets.only(
          bottom: isDesktop ? 0 : 12), // لا يوجد هامش سفلي في GridView
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias, // لمنع تجاوز الصورة للحواف الدائرية
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // يمكنك إضافة إجراء هنا، مثل عرض صفحة تفاصيل السائق
          print('Tapped on driver: ${driver.fullName}');
          // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverDetailsPage(driver: driver)));
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة السائق (Placeholder)
                  CircleAvatar(
                    radius: isDesktop ? 30 : 25,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: driver.profileImageUrl != null
                        ? NetworkImage(driver.profileImageUrl!)
                        : null, // استخدام NetworkImage إذا كان الرابط موجودًا
                    child: driver.profileImageUrl == null
                        ? Icon(
                            LucideIcons.user,
                            size: isDesktop ? 35 : 30,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // اسم السائق والتقييم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // الرقم بعد الاسم
                        Text(
                          driver.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 4),
                        _buildRatingStars(
                            context, driver.rating, driver.numberOfRatings),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
              const SizedBox(height: 12),

              // تفاصيل السيارة
              _buildDetailRow(
                context: context,
                icon: LucideIcons.car,
                label: local.translate('vehicle'), // مفتاح ترجمة
                value: '${driver.carModel} (${driver.carColor})',
              ),
              _buildDetailRow(
                context: context,
                icon: LucideIcons.hash, // أيقونة مناسبة للوحة
                label: local.translate('plate_number'), // مفتاح ترجمة
                value: driver.carPlateNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // لعرض نجوم التقييم
  Widget _buildRatingStars(
      BuildContext context, double rating, int ratingCount) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      IconData icon;
      Color color = Colors.amber;
      if (i < fullStars) {
        icon = Icons.star;
      } else if (i == fullStars && hasHalfStar) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
        color = Colors.grey; // لون النجمة الفارغة
      }
      stars.add(Icon(icon, color: color, size: 18));
    }

    // إضافة عدد التقييمات إذا كان أكبر من صفر
    if (ratingCount > 0) {
      stars.add(const SizedBox(width: 4));
      stars.add(Text(
        '($ratingCount)', // يمكنك استخدام local.translate إذا أردت تنسيقًا معينًا
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ));
    } else {
      // رسالة في حالة عدم وجود تقييمات
      stars.add(const SizedBox(width: 4));
      stars.add(Text(
        local.translate('no_ratings_yet'), // مفتاح ترجمة
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ));
    }

    return Row(children: stars);
  }

  // ودجت لعرض صف تفاصيل (مثل السيارة أو اللوحة)
  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon,
              size: isDesktop ? 18 : 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: ',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis, // جيد إضافته للـ label أيضًا
              maxLines: 1,
            ),
          ),
          Expanded(
            // للسماح للنص بالتمدد وأخذ المساحة المتبقية
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor, // استخدام اللون الممرر إن وجد
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // تأكد من وجود maxLines هنا أيضًا
              // لمنع تجاوز النص
            ),
          ),
        ],
      ),
    );
  }

  // ودجت لعرض رسالة الخطأ
  Widget _buildErrorWidget(
      BuildContext context, AppLocalizations local, Object? error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              local.translate('error_loading_drivers'), // مفتاح ترجمة
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(), // عرض تفاصيل الخطأ للمساعدة في التصحيح
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDrivers, // محاولة إعادة التحميل
              label: Text(local.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت لعرض حالة عدم وجود بيانات
  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users, // أيقونة مناسبة للسائقين
            size: 60,
            color: theme.colorScheme.secondary.withOpacity(0.6),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)
                .translate('check_back_later_drivers'), // مفتاح ترجمة
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
