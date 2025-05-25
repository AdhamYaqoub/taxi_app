class Trip {
  final int tripId;
  final int userId;
  final int? driverId; // جعله اختياريًا
  final Location startLocation;
  final Location endLocation;
  final double distance;
  final double estimatedFare;
  final double actualFare; // تغيير من earnings إلى actualFare
  final String status;
  final DateTime requestedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startTime; // جعله اختياريًا
  final DateTime? endTime; // جعله اختياريًا
  final DateTime? acceptedAt; // Added field for accepted time
  final String paymentMethod;
  final String? driverName;
  final String? userName;

  Trip({
    required this.tripId,
    required this.userId,
    this.driverId,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.estimatedFare,
    required this.paymentMethod, // Initialize paymentMethod
    required this.actualFare,
    required this.status,
    required this.requestedAt,
    required this.createdAt,
    required this.updatedAt,
    this.startTime,
    this.endTime,
    this.acceptedAt,
    this.driverName,
    this.userName,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      driverId: json['driverId'] as int?,
      startLocation: Location.fromJson(json['startLocation']),
      endLocation: Location.fromJson(json['endLocation']),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      actualFare: (json['actualFare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      requestedAt: DateTime.parse(json['requestedAt'] as String? ?? ''),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? ''),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      driverName: json['driverName'] as String? ?? 'Unknown',
      userName: json['userName'] as String? ?? 'Unknown',
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null, // 👈 هذا السطر ناقص حالياً
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'userId': userId,
      'driverId': driverId,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'distance': distance,
      'estimatedFare': estimatedFare,
      'actualFare': actualFare,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // إذا كنت تفضل استخدام earnings كاسم بدلاً من actualFare
  double get earnings => actualFare;
}

class Location {
  final String address;
  final double longitude;
  final double latitude;

  Location({
    required this.address,
    required this.longitude,
    required this.latitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      longitude: json['coordinates'][0],
      latitude: json['coordinates'][1],
    );
  }
}
