import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حالة الطرق والحواجز',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
  Map<String, List<Map<String, dynamic>>> cityRoads = {};
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;

  // التوكن المباشر (تحذير: هذه الطريقة غير آمنة)
  final String botToken = '7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ';

  final List<String> availableCities = [
    "نابلس",
    "سلفيت",
    "رام الله",
    "الخليل",
    "بيت لحم",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (selectedCity != null) {
        fetchDataFromTelegramBot(selectedCity!);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (selectedCity != null && !isLoading) {
        fetchDataFromTelegramBot(selectedCity!);
      }
    }
  }

  Future<void> fetchDataFromTelegramBot(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://api.telegram.org/bot$botToken/getUpdates'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          final messages = data['result'] as List<dynamic>;
          
          for (var cityName in availableCities) {
            final cityRoadsList = await _parseMessages(messages, cityName);
            setState(() {
              cityRoads[cityName] = cityRoadsList;
            });
          }
          
          final now = DateTime.now();
          setState(() {
            lastUpdated = 'آخر تحديث: ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
            isLoading = false;
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
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _parseMessages(List<dynamic> messages, String city) async {
    final List<Map<String, dynamic>> result = [];
    final cityLower = city.toLowerCase();
    
    final List<String> roadKeywords = [
      'مدخل', 'شارع', 'طريق', 'مفرق', 'دوار', 'تقاطع',
      'entrance', 'street', 'road', 'intersection', 'junction'
    ];
    
    final List<String> directionKeywords = [
      'شمالي', 'جنوبي', 'شرقي', 'غربي',
      'north', 'south', 'east', 'west'
    ];
    
    for (var msg in messages) {
      try {
        if (msg['message']?['text'] == null) continue;
        
        final text = msg['message']['text'].toString();
        final lowerText = text.toLowerCase();
        
        if (!_isMessageRelatedToCity(text, city)) continue;
        
        final lines = text.split('\n');
        
        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          
          if (line.toLowerCase().trim() == cityLower) continue;
          
          if (_isRoadInformation(line, roadKeywords)) {
            final roadInfo = _extractRoadInfo(line, city, roadKeywords, directionKeywords);
            if (roadInfo != null) {
              result.add(roadInfo);
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing message: $e');
      }
    }
    
    return result;
  }

  bool _isMessageRelatedToCity(String text, String city) {
    final lowerText = text.toLowerCase();
    final cityLower = city.toLowerCase();
    
    if (lowerText.contains(cityLower)) return true;
    
    final cityKeywords = {
      'نابلس': ['جبل النار', 'جبل عيبال', 'جبل جرزيم'],
      'رام الله': ['البيرة', 'بيتونيا', 'البيرة'],
      'الخليل': ['جبل الخليل', 'الخليل القديمة'],
      'بيت لحم': ['بيت ساحور', 'بيت جالا'],
      'سلفيت': ['كفر قاسم', 'بديا']
    };
    
    if (cityKeywords.containsKey(city)) {
      for (var keyword in cityKeywords[city]!) {
        if (lowerText.contains(keyword.toLowerCase())) return true;
      }
    }
    
    return false;
  }

  bool _isRoadInformation(String line, List<String> roadKeywords) {
    final lowerLine = line.toLowerCase();
    
    for (var keyword in roadKeywords) {
      if (lowerLine.contains(keyword)) return true;
    }
    
    if (lowerLine.contains('✅') || lowerLine.contains('❌') || lowerLine.contains('⚠️')) {
      return true;
    }
    
    final statusWords = ['مفتوح', 'مغلق', 'مزدحم', 'open', 'closed', 'busy'];
    for (var word in statusWords) {
      if (lowerLine.contains(word)) return true;
    }
    
    return false;
  }

  Map<String, dynamic>? _extractRoadInfo(String line, String city, List<String> roadKeywords, List<String> directionKeywords) {
    try {
      String roadName = '';
      String status = '';
      String note = '';
      
      for (var keyword in roadKeywords) {
        if (line.toLowerCase().contains(keyword)) {
          final parts = line.split(RegExp(r'[:|-]'));
          if (parts.isNotEmpty) {
            roadName = parts[0].trim();
            for (var otherCity in availableCities) {
              if (otherCity != city) {
                roadName = roadName.replaceAll(otherCity, '');
              }
            }
            break;
          }
        }
      }
      
      if (roadName.isEmpty) {
        roadName = line;
        for (var otherCity in availableCities) {
          if (otherCity != city) {
            roadName = roadName.replaceAll(otherCity, '');
          }
        }
        roadName = roadName.replaceAll(RegExp(r'[✅❌⚠️📍]'), '');
        for (var keyword in roadKeywords) {
          roadName = roadName.replaceAll(keyword, '');
        }
      }
      
      roadName = roadName.trim();
      
      if (line.contains('✅') || line.toLowerCase().contains('مفتوح') || line.toLowerCase().contains('open')) {
        status = 'مفتوح';
      } else if (line.contains('❌') || line.toLowerCase().contains('مغلق') || line.toLowerCase().contains('closed')) {
        status = 'مغلق';
      } else if (line.contains('⚠️') || line.toLowerCase().contains('مزدحم') || line.toLowerCase().contains('busy')) {
        status = 'مزدحم';
      }
      
      final parts = line.split(RegExp(r'[:|-]'));
      if (parts.length > 2) {
        note = parts[2].trim();
      }
      
      if (roadName.isNotEmpty && status.isNotEmpty) {
        return _createRoadMap(roadName, status, note);
      }
    } catch (e) {
      debugPrint('Error extracting road info: $e');
    }
    
    return null;
  }

  Map<String, dynamic> _createRoadMap(String name, String status, String note) {
    return {
      "name": name,
      "status": status,
      "note": note,
      "icon": _getIconForStatus(status),
    };
  }

  IconData _getIconForStatus(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('مفتوح')) return Icons.directions_car;
    if (statusLower.contains('مغلق')) return Icons.block;
    if (statusLower.contains('مزدحم')) return Icons.traffic;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    // تحديد نوع الجهاز
    final isWeb = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("حالة الطرق والحواجز", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (lastUpdated.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  lastUpdated,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: isWeb ? _buildWebLayout() : _buildMobileLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => fetchDataFromTelegramBot(selectedCity ?? availableCities.first),
        child: Icon(Icons.refresh, color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 4,
        tooltip: 'تحديث البيانات',
      ),
    );
  }

  Widget _buildWebLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القسم الجانبي للمدن
          Container(
            width: 300,
            margin: EdgeInsets.only(left: 16),
            child: Column(
              children: [
                _buildCitySelector(),
                SizedBox(height: 24),
                if (errorMessage != null) _buildErrorWidget(),
              ],
            ),
          ),
          // القسم الرئيسي لعرض الطرق
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedCity != null) _buildCityHeader(),
                  SizedBox(height: 16),
                  Expanded(child: _buildWebRoadsGrid()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCitySelector(),
          SizedBox(height: 20),
          if (errorMessage != null) _buildErrorWidget(),
          if (selectedCity != null) _buildCityHeader(),
          SizedBox(height: 12),
          Expanded(child: _buildRoadsList()),
        ],
      ),
    );
  }

  Widget _buildWebRoadsGrid() {
    if (isLoading && (cityRoads[selectedCity]?.isEmpty ?? true)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("جاري تحميل البيانات...", style: TextStyle(color: Colors.blue[800])),
          ],
        ),
      );
    }

    final roads = cityRoads[selectedCity] ?? [];
    if (roads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 72, color: Colors.blue[200]),
            SizedBox(height: 16),
            Text(
              selectedCity == null ? "الرجاء اختيار المدينة" : "لا توجد بيانات متاحة",
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
            if (selectedCity != null)
              TextButton(
                onPressed: () => fetchDataFromTelegramBot(selectedCity!),
                child: Text("إعادة المحاولة", style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      );
    }

    // تصنيف الطرق حسب الحالة
    final openRoads = roads.where((road) => road["status"].toString().contains('مفتوح')).toList();
    final closedRoads = roads.where((road) => road["status"].toString().contains('مغلق')).toList();
    final busyRoads = roads.where((road) => road["status"].toString().contains('مزدحم')).toList();

    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: () => fetchDataFromTelegramBot(selectedCity!),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (closedRoads.isNotEmpty) ...[
              _buildStatusHeader('مغلق', closedRoads.length, Colors.red[700]!),
              _buildRoadsGrid(closedRoads),
            ],
            if (busyRoads.isNotEmpty) ...[
              _buildStatusHeader('مزدحم', busyRoads.length, Colors.orange[700]!),
              _buildRoadsGrid(busyRoads),
            ],
            if (openRoads.isNotEmpty) ...[
              _buildStatusHeader('مفتوح', openRoads.length, Colors.green[700]!),
              _buildRoadsGrid(openRoads),
            ],
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status, int count, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24, bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'مفتوح' ? Icons.check_circle :
              status == 'مغلق' ? Icons.cancel :
              Icons.warning,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'الطرق $status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadsGrid(List<Map<String, dynamic>> roads) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: roads.length,
      itemBuilder: (context, index) => RoadStatusCard(
        road: roads[index],
        isWeb: true,
      ),
    );
  }

  Widget _buildCitySelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      shadowColor: Colors.blue.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.location_city, color: Colors.blue[700]),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "اختر المدينة",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                ),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: availableCities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                      city,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCity = val;
                  });
                  fetchDataFromTelegramBot(val!);
                },
                value: selectedCity,
                style: TextStyle(color: Colors.blue[800]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: errorMessage != null ? 1 : 0,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(Icons.error_outline, color: Colors.red),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage ?? '',
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
            ),
            child: Icon(Icons.location_on, color: Colors.blue[700]),
          ),
          SizedBox(width: 12),
          Text(
            "حالة الطرق في $selectedCity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue[800],
            ),
          ),
          Spacer(),
          if (isLoading)
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildRoadsList() {
    if (isLoading && (cityRoads[selectedCity]?.isEmpty ?? true)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("جاري تحميل البيانات...", style: TextStyle(color: Colors.blue[800])),
          ],
        ),
      );
    }

    final roads = cityRoads[selectedCity] ?? [];
    if (roads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 72, color: Colors.blue[200]),
            SizedBox(height: 16),
            Text(
              selectedCity == null ? "الرجاء اختيار المدينة" : "لا توجد بيانات متاحة",
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
            if (selectedCity != null)
              TextButton(
                onPressed: () => fetchDataFromTelegramBot(selectedCity!),
                child: Text("إعادة المحاولة", style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      );
    }

    final openRoads = roads.where((road) => road["status"].toString().contains('مفتوح')).toList();
    final closedRoads = roads.where((road) => road["status"].toString().contains('مغلق')).toList();
    final busyRoads = roads.where((road) => road["status"].toString().contains('مزدحم')).toList();

    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: () => fetchDataFromTelegramBot(selectedCity!),
      child: ListView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          if (closedRoads.isNotEmpty) _buildStatusSection('مغلق', closedRoads, Colors.red[700]!),
          if (busyRoads.isNotEmpty) _buildStatusSection('مزدحم', busyRoads, Colors.orange[700]!),
          if (openRoads.isNotEmpty) _buildStatusSection('مفتوح', openRoads, Colors.green[700]!),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStatusSection(String status, List<Map<String, dynamic>> roads, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              bottom: BorderSide(color: color.withOpacity(0.2), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == 'مفتوح' ? Icons.check_circle :
                  status == 'مغلق' ? Icons.cancel :
                  Icons.warning,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'الطرق $status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '${roads.length}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...roads.map((road) => RoadStatusCard(road: road)).toList(),
        SizedBox(height: 8),
      ],
    );
  }
}

class RoadStatusCard extends StatelessWidget {
  final Map<String, dynamic> road;
  final bool isWeb;

  const RoadStatusCard({
    Key? key,
    required this.road,
    this.isWeb = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = road["status"].toString().toLowerCase();
    final Color statusColor = status.contains('مفتوح') ? Colors.green[700]! :
                            status.contains('مغلق') ? Colors.red[700]! :
                            status.contains('مزدحم') ? Colors.orange[700]! : Colors.grey;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // يمكن إضافة تفاعل عند النقر هنا
        },
        child: Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(road["icon"], size: 24, color: statusColor),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          road["name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isWeb ? 18 : 16,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          road["status"],
                          style: TextStyle(
                            color: statusColor,
                            fontSize: isWeb ? 15 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (road["note"]?.isNotEmpty ?? false) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          road["note"],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isWeb ? 14 : 13,
                          ),
                          maxLines: isWeb ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}