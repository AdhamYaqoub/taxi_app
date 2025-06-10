import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حالة الطرق والحواجز',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Tajawal',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF7F9FC),
        cardColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.amber[700]!,
          secondary: Colors.amber[500]!,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Tajawal',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          primary: Colors.amber[400]!,
          secondary: Colors.amber[300]!,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: RoadStatusScreen(),
    );
  }
}

class RoadStatusScreen extends StatefulWidget {
  @override
  _RoadStatusScreenState createState() => _RoadStatusScreenState();
}

class _RoadStatusScreenState extends State<RoadStatusScreen> {
  String? selectedCity;
  bool isLoading = false;
  String lastUpdated = '';
  Map<String, Map<String, Map<String, dynamic>>> cityRoads = {};
  String? errorMessage;
  Timer? _refreshTimer;

  final String botToken = '7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ';
  final List<String> availableCities = ["نابلس", "سلفيت", "رام الله", "الخليل", "بيت لحم"];

  @override
  void initState() {
    super.initState();
    selectedCity = availableCities.first;
    fetchDataFromTelegramBot(selectedCity!);
    
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (selectedCity != null) {
        fetchDataFromTelegramBot(selectedCity!);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchDataFromTelegramBot(String city) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final response = await http.get(Uri.parse('https://api.telegram.org/bot$botToken/getUpdates'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          final messages = data['result'] as List<dynamic>;
          
          Map<String, Map<String, dynamic>> parsedRoads = {};
          
          // START: المنطق الجديد والمحسّن الذي يعتمد على التاريخ
          for (var msg in messages) {
            try {
              if (msg['message']?['text'] == null) continue;
              final text = msg['message']['text'].toString();
              if (!_isMessageRelatedToCity(text, city)) continue;
              
              final int messageDate = msg['message']['date'];
              final lines = text.split('\n');

              for (var line in lines) {
                if (line.trim().isEmpty) continue;
                // تمرير تاريخ الرسالة للدالة
                final roadInfo = _extractRoadInfo(line, messageDate);
                if (roadInfo != null) {
                  final roadName = roadInfo['name'] as String;
                  // التحقق إذا كان الطريق موجودًا بالفعل وإذا كانت الرسالة الجديدة أحدث
                  if (!parsedRoads.containsKey(roadName) || (parsedRoads[roadName]!['date'] as int) < messageDate) {
                    parsedRoads[roadName] = roadInfo;
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing message: $e');
            }
          }
          // END: المنطق الجديد والمحسّن

          setState(() {
            cityRoads[city] = parsedRoads;
            lastUpdated = 'آخر تحديث: ${DateFormat('h:mm a', 'ar').format(DateTime.now())}';
          });

        } else {
          throw Exception('استجابة غير صحيحة من السيرفر: ${data['description']}');
        }
      } else {
        throw Exception('فشل في الاتصال: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _isMessageRelatedToCity(String text, String city) {
    return text.toLowerCase().contains(city.toLowerCase());
  }

  // START: تعديل الدالة لتستقبل تاريخ الرسالة
  Map<String, dynamic>? _extractRoadInfo(String line, int messageDate) {
    try {
      String status = '';
      if (line.contains('✅') || line.toLowerCase().contains('مفتوح')) status = 'مفتوح';
      else if (line.contains('❌') || line.toLowerCase().contains('مغلق')) status = 'مغلق';
      else if (line.contains('⚠️') || line.toLowerCase().contains('ازمة') || line.toLowerCase().contains('مزدحم')) status = 'مزدحم';
      
      if (status.isNotEmpty) {
        String roadName = line
            .replaceAll(RegExp(r'[✅❌⚠️]'), '')
            .replaceAll('مفتوح', '')
            .replaceAll('مغلق', '')
            .replaceAll('ازمة', '')
            .replaceAll('مزدحم', '')
            .trim();
        
        // التأكد من أن اسم الطريق ليس فارغًا بعد التنظيف
        if (roadName.isEmpty) return null;
        
        return {
          "name": roadName,
          "status": status,
          "date": messageDate, // إضافة تاريخ الرسالة للبيانات
        };
      }
    } catch (e) {
      debugPrint('Error extracting road info: $e');
    }
    return null;
  }
  // END: تعديل الدالة
  
  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("حالة الطرق والحواجز", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 1,
        actions: [
          if (lastUpdated.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  lastUpdated,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
            ),
        ],
      ),
      body: isWeb ? _buildWebLayout() : _buildMobileLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedCity == null ? null : () => fetchDataFromTelegramBot(selectedCity!),
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'تحديث البيانات',
      ),
    );
  }

  // --- تصميم الويب ---
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWebSidebar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMessage != null) _buildErrorWidget(),
                if (selectedCity != null) _buildCityHeader(),
                SizedBox(height: 16),
                Expanded(child: _buildRoadsContent()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text("المدن", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: availableCities.length,
              itemBuilder: (context, index) {
                final city = availableCities[index];
                final isSelected = city == selectedCity;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.location_city_outlined, color: isSelected ? Theme.of(context).colorScheme.primary : null),
                    title: Text(city, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    onTap: () {
                      setState(() => selectedCity = city);
                      fetchDataFromTelegramBot(city);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- تصميم الموبايل ---
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCitySelector(),
          SizedBox(height: 12),
          if (errorMessage != null) _buildErrorWidget(),
          if (selectedCity != null) _buildCityHeader(),
          SizedBox(height: 12),
          Expanded(child: _buildRoadsContent()),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        hintText: 'اختر مدينة',
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
      items: availableCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() => selectedCity = val);
          fetchDataFromTelegramBot(val);
        }
      },
      value: selectedCity,
    );
  }

  // --- محتوى مشترك ---
  Widget _buildRoadsContent() {
    if (isLoading && (cityRoads[selectedCity] == null || cityRoads[selectedCity]!.isEmpty)) {
      return _buildShimmerLoading();
    }
    
    final roadsMap = cityRoads[selectedCity] ?? {};
    final roads = roadsMap.values.toList();
    
    if (roads.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 72, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              "لا توجد بيانات متاحة حاليًا",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    final openRoads = roads.where((r) => r["status"] == 'مفتوح').toList();
    final closedRoads = roads.where((r) => r["status"] == 'مغلق').toList();
    final busyRoads = roads.where((r) => r["status"] == 'مزدحم').toList();

    return RefreshIndicator(
      onRefresh: () => fetchDataFromTelegramBot(selectedCity!),
      child: ListView(
        children: [
          if (closedRoads.isNotEmpty) _buildStatusSection('مغلق', closedRoads, Colors.red.shade400),
          if (busyRoads.isNotEmpty) _buildStatusSection('مزدحم', busyRoads, Colors.orange.shade400),
          if (openRoads.isNotEmpty) _buildStatusSection('مفتوح', openRoads, Colors.green.shade400),
        ],
      ),
    );
  }
  
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 150.0, height: 24.0, color: Colors.white),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 70.0, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 70.0, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          SizedBox(width: 12),
          Expanded(child: Text(errorMessage ?? '', style: TextStyle(color: Colors.red.shade900))),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () => setState(() => errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCityHeader() {
    return Text("حالة الطرق في $selectedCity", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildStatusSection(String status, List<Map<String, dynamic>> roads, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15)),
                child: Icon(
                  status == 'مفتوح' ? Icons.check_circle_outline : status == 'مغلق' ? Icons.highlight_off : Icons.traffic_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text('الطرق ال$status (${roads.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Divider(height: 24, thickness: 1),
          ...roads.map((road) => RoadStatusCard(road: road)).toList(),
        ],
      ),
    );
  }
}

class RoadStatusCard extends StatelessWidget {
  final Map<String, dynamic> road;

  const RoadStatusCard({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = road["status"] as String;
    final Color statusColor = status == 'مفتوح' ? Colors.green.shade400 : status == 'مغلق' ? Colors.red.shade400 : Colors.orange.shade400;
    final IconData icon = status == 'مفتوح' ? Icons.gpp_good_outlined : status == 'مغلق' ? Icons.cancel_outlined : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              road["name"] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}