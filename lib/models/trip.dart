class Trip {
  final int tripId;
  final int driverId;
  final String startLocation;
  final String endLocation;
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double earnings;

  Trip({
    required this.tripId,
    required this.driverId,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.earnings,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'],
      driverId: json['driverId'],
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      distance: json['distance'].toDouble(),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'],
      earnings: json['earnings'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'driverId': driverId,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'distance': distance,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'earnings': earnings,
    };
  }
}
