import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      ),
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
  List<Map<String, dynamic>> roads = [];
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();

  // التوكن المباشر (تحذير: هذه الطريقة غير آمنة)
  final String botToken = '7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ'; // استبدل هذا بالتوكن الحقيقي

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
  }

  @override
  void dispose() {
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
          final parsedRoads = await _parseMessages(messages, city);
          
          final now = DateTime.now();
          setState(() {
            roads = parsedRoads;
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
    
    for (var msg in messages) {
      try {
        if (msg['message']?['text'] == null) continue;
        
        final text = msg['message']['text'].toString().toLowerCase();
        if (!text.contains(cityLower)) continue;
        
        final parsed = _parseMessageText(msg['message']['text'], city);
        if (parsed.isNotEmpty) {
          result.addAll(parsed);
        }
      } catch (e) {
        debugPrint('Error parsing message: $e');
      }
    }
    
    return result;
  }

  List<Map<String, dynamic>> _parseMessageText(String message, String city) {
    final List<Map<String, dynamic>> result = [];
    final lines = message.split('\n');
    
    try {
      // الصيغة 1: المدينة: الاسم - الحالة - الملاحظات
      if (message.contains(':') && message.contains('-')) {
        final parts = message.split(':');
        if (parts.length > 1) {
          final roadParts = parts[1].split('-').map((e) => e.trim()).toList();
          if (roadParts.length >= 2) {
            result.add(_createRoadMap(
              roadParts[0],
              roadParts[1],
              roadParts.length > 2 ? roadParts[2] : '',
            ));
          }
        }
      }
      // الصيغة 2: سطر لكل معلومة
      else if (message.contains('الحالة:')) {
        String name = '', status = '', note = '';
        
        for (var line in lines) {
          if (line.contains('الموقع:') || line.contains('الشارع:')) {
            name = line.split(':').last.trim();
          } else if (line.contains('الحالة:')) {
            status = line.split(':').last.trim();
          } else if (line.contains('الملاحظات:') || line.contains('السبب:')) {
            note = line.split(':').last.trim();
          }
        }
        
        if (name.isNotEmpty && status.isNotEmpty) {
          result.add(_createRoadMap(name, status, note));
        }
      }
      // الصيغة 3: مع رموز
      else if (message.contains('✅') || message.contains('❌') || message.contains('⚠️')) {
        for (var line in lines) {
          if (line.contains('📍') || line.contains(city)) continue;
          
          final emojiMatch = RegExp(r'([✅❌⚠️])').firstMatch(line);
          if (emojiMatch != null) {
            final parts = line.split(emojiMatch.group(0)!);
            if (parts.length >= 2) {
              final status = emojiMatch.group(0)! == '✅' ? 'مفتوح' :
                           emojiMatch.group(0)! == '❌' ? 'مغلق' : 'مزدحم';
              result.add(_createRoadMap(
                parts[1].split(':').first.trim(),
                status,
                parts.length > 2 ? parts[2].trim() : '',
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
    
    return result;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("حالة الطرق والحواجز"),
        centerTitle: true,
        actions: [
          if (lastUpdated.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  lastUpdated,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCitySelector(),
            SizedBox(height: 16),
            if (errorMessage != null) _buildErrorWidget(),
            if (selectedCity != null) _buildCityHeader(),
            SizedBox(height: 8),
            Expanded(child: _buildRoadsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedCity == null ? null : () => fetchDataFromTelegramBot(selectedCity!),
        child: Icon(Icons.refresh),
        tooltip: 'تحديث البيانات',
      ),
    );
  }

  Widget _buildCitySelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اختر المدينة",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: availableCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCity = val;
                  roads = [];
                });
                fetchDataFromTelegramBot(val!);
              },
              value: selectedCity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            "حالة الطرق في $selectedCity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadsList() {
    if (isLoading && roads.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (roads.isEmpty) {
      return Center(
        child: Text(
          selectedCity == null ? "الرجاء اختيار المدينة" : "لا توجد بيانات متاحة",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchDataFromTelegramBot(selectedCity!),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: roads.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == roads.length) {
            return Center(child: CircularProgressIndicator());
          }
          return RoadStatusCard(road: roads[index]);
        },
      ),
    );
  }
}

class RoadStatusCard extends StatelessWidget {
  final Map<String, dynamic> road;

  const RoadStatusCard({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = road["status"].toString().toLowerCase();
    final Color statusColor = status.contains('مفتوح') ? Colors.green :
                            status.contains('مغلق') ? Colors.red :
                            status.contains('مزدحم') ? Colors.orange : Colors.grey;
    
    final IconData statusIcon = status.contains('مفتوح') ? Icons.check_circle :
                              status.contains('مغلق') ? Icons.cancel :
                              status.contains('مزدحم') ? Icons.warning : Icons.help_outline;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(road["icon"], size: 28, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    road["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 30),
              ],
            ),
            SizedBox(height: 10),
            if (road["note"]?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ملاحظات:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    road["note"],
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "الحالة: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  road["status"],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}