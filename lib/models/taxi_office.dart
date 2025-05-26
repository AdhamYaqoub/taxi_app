import 'package:latlong2/latlong.dart';

class TaxiOffice {
  final String id;
  final int? officeId; // جعله اختياريًا
  final String? officeIdentifier; // جعله اختياريًا
  final String name;
  final OfficeLocation location;
  final OfficeContact contact;
  final WorkingHours? workingHours;
  final bool isActive;
  final ManagerInfo? manager;
  final String phone;

  TaxiOffice({
    required this.id,
    this.officeId,
    this.officeIdentifier,
    required this.name,
    required this.location,
    required this.contact,
    this.workingHours,
    required this.isActive,
    this.manager,
    required this.phone,
  });

  factory TaxiOffice.fromJson(Map<String, dynamic> json) {
    return TaxiOffice(
      id: json['id'] ?? json['_id'] ?? '', // تأمين ضد القيم الفارغة
      officeId: json['officeId'] as int?,
      officeIdentifier: json['officeIdentifier'] as String?,
      name: json['name'] ?? 'غير معروف',
      location: OfficeLocation.fromJson(json), // تم التعديل هنا
      contact: OfficeContact.fromJson(json['contact'] ?? {}),
      phone: json['phone']?.toString() ??
          'غير متوفر', // تحويل لأString إذا كان رقمًا

      workingHours: json['workingHours'] != null
          ? WorkingHours.fromJson(json['workingHours'])
          : null,
      isActive: json['isActive'] ?? true,
      manager: json['manager'] != null
          ? ManagerInfo.fromJson(json['manager'])
          : null,
    );
  }

  LatLng getLatLng() {
    return LatLng(
      location.latitude,
      location.longitude,
    );
  }
}

class OfficeLocation {
  final double latitude;
  final double longitude;
  final String address;

  OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      latitude: (json['coordinates']?['latitude'] ?? 0.0).toDouble(),
      longitude: (json['coordinates']?['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? 'غير معروف',
    );
  }
}

class OfficeContact {
  final String phone;
  final String email;

  OfficeContact({
    required this.phone,
    required this.email,
  });

  factory OfficeContact.fromJson(Map<String, dynamic> json) {
    return OfficeContact(
      phone: json['phone'] ?? 'غير متوفر',
      email: json['email'] ?? 'غير متوفر',
    );
  }
}

class WorkingHours {
  final String from;
  final String to;

  WorkingHours({
    required this.from,
    required this.to,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      from: json['from'],
      to: json['to'],
    );
  }

  // دالة مساعدة لعرض ساعات العمل بتنسيق جميل
  String getFormattedHours() {
    return '$from - $to';
  }
}

class ManagerInfo {
  final String id;
  final int managerId;
  final String fullName;
  final String email;
  final String phone;

  ManagerInfo({
    required this.id,
    required this.managerId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory ManagerInfo.fromJson(Map<String, dynamic> json) {
    return ManagerInfo(
      id: json['_id'] ?? json['id'],
      managerId: json['managerId'] ?? json['userId'],
      fullName: json['user']?['fullName'] ?? 'غير معروف',
      email: json['user']?['email'] ?? 'غير معروف',
      phone: json['user']?['phone'] ?? 'غير معروف',
    );
  }
}
