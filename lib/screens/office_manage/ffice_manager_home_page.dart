import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/driver.dart'; // مسار صحيح
import 'package:taxi_app/services/taxi_office_api.dart'; // مسار صحيح

class OfficeManagerHomePage extends StatefulWidget {
  final int officeId;
  final String token;

  const OfficeManagerHomePage({
    super.key,
    required this.officeId,
    required this.token,
  });

  @override
  _OfficeManagerHomePageState createState() => _OfficeManagerHomePageState();
}

class _OfficeManagerHomePageState extends State<OfficeManagerHomePage> {
  // تم إزالة `_officeData` حيث لم يتم استخدامها مباشرة.
  List<Driver> _activeDrivers = [];
  bool _isLoading = true;

  // تعريف متغيرات لتخزين الإحصائيات مؤقتًا
  int _driversCount = 0;
  int _dailyTrips = 0;
  int _dailyEarnings = 0;

  @override
  void initState() {
    super.initState();
    _loadOfficeData();
  }

  Future<void> _loadOfficeData() async {
    setState(() => _isLoading = true);
    print('Loading office data for ID: ${widget.officeId}');

    try {
      // جلب بيانات المكتب (لم يتم استخدامها هنا، ولكن يمكن تخزينها إذا لزم الأمر)
      // final office = await TaxiOfficeApi.getOfficeDetails(widget.officeId, widget.token);

      // جلب الإحصائيات
      final stats =
          await TaxiOfficeApi.getOfficeStats(widget.officeId, widget.token);
      final dailyStats =
          await TaxiOfficeApi.getDailyStats(widget.officeId, widget.token);

      // جلب السائقين النشطين
      final drivers =
          await TaxiOfficeApi.getOfficeDrivers(widget.officeId, widget.token);
      final activeDrivers =
          drivers.where((driver) => driver.isAvailable).toList();

      setState(() {
        _activeDrivers = activeDrivers;
        _driversCount = stats['driversCount'] ?? 0;
        _dailyTrips = dailyStats['dailyTripsCount'] ?? 0;
        _dailyEarnings = dailyStats['dailyEarnings'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading office data: $e');
      setState(() => _isLoading = false);
      // يمكنك إضافة معالجة الأخطاء هنا (مثال: إظهار SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('error_loading_data')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      // أضفنا RefreshIndicator للصفحة بأكملها
      onRefresh: _loadOfficeData,
      child: SingleChildScrollView(
        // لضمان التمرير إذا كان المحتوى أكبر من الشاشة
        physics:
            const AlwaysScrollableScrollPhysics(), // لجعل RefreshIndicator يعمل حتى لو المحتوى صغير
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)
                    .translate('welcome_office_manager'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              _buildStatsGrid(context),
              const SizedBox(height: 30),
              Text(
                AppLocalizations.of(context).translate('active_drivers_now'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 15),
              // Expanded لم تعد ضرورية هنا لأننا في SingleChildScrollView
              _buildActiveDriversList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // لمنع التمرير المتداخل
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(
          context,
          AppLocalizations.of(context).translate('drivers_count'),
          _driversCount.toString(),
          LucideIcons.users,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          AppLocalizations.of(context).translate('todayTrips'),
          _dailyTrips.toString(),
          LucideIcons.car,
          Colors.green,
        ),
        _buildStatCard(
          context,
          AppLocalizations.of(context).translate('today_earnings'),
          '$_dailyEarnings',
          LucideIcons.dollarSign,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDriversList(BuildContext context) {
    if (_activeDrivers.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_active_drivers'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // لمنع التمرير المتداخل
      itemCount: _activeDrivers.length,
      itemBuilder: (context, index) {
        final driver = _activeDrivers[index];
        final status = driver.isAvailable
            ? AppLocalizations.of(context).translate('active')
            : AppLocalizations.of(context).translate('status_inactive');

        // driver.driverUserId يمكن أن يكون معرفًا (ID)، لذا تم تغيير النص ليتناسب.
        // إذا كان driver.driverUserId هو عدد الرحلات، فيجب تغيير اسم الخاصية في الموديل.
        final tripsText =
            '${driver.earnings} ${AppLocalizations.of(context).translate('\$')}';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              backgroundImage: driver.profileImageUrl != null
                  ? NetworkImage(driver.profileImageUrl!)
                  : null,
              child: driver.profileImageUrl == null
                  ? Icon(Icons.person,
                      color: Theme.of(context).colorScheme.onSecondary)
                  : null,
            ),
            title: Text(
              driver.fullName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: driver.isAvailable
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: driver.isAvailable
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  tripsText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                LucideIcons.mapPin,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                // TODO: Implement logic to show driver location
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Show location for ${driver.fullName}')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
