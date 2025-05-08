class Driver {
  final int userId;
  final String fullName;
  final String? profileImageUrl;
  final String carModel;
  final String carColor;
  final String carPlateNumber;
  final double rating;
  final int numberOfRatings;
  bool isAvailable;
  final String taxiOffice;
  final String phone;
  final String email;
  final double earnings;

  Driver({
    required this.userId,
    required this.fullName,
    this.profileImageUrl,
    required this.carModel,
    required this.carColor,
    required this.carPlateNumber,
    required this.rating,
    required this.numberOfRatings,
    required this.taxiOffice,
    required this.phone,
    required this.email,
    required this.earnings,
    required this.isAvailable,
  });

  // مثال على Factory Constructor لتحويل JSON إلى Driver object
  // ستحتاج لتعديله ليطابق شكل الـ JSON الفعلي من الـ API الخاص بك
  factory Driver.fromJson(Map<String, dynamic> json) {
    // مثال افتراضي جداً، قد تحتاج لجلب الاسم من مستند User المرتبط
    // أو قد يكون الاسم مكرراً في مستند Driver لتسهيل الجلب
    final userDetails =
        json['user'] as Map<String, dynamic>?; // افتراض وجود كائن user متداخل
    final carDetails = json['carDetails'] as Map<String, dynamic>? ?? {};

    return Driver(
      userId: userDetails?['userId'] ??
          json['userId'] ??
          0, // تأكد من كيفية الحصول على userId
      fullName: userDetails?['fullName'] ??
          json['fullName'] ??
          'Unknown Driver', // مثال
      profileImageUrl: json['profileImageUrl'] as String?,
      carModel: carDetails['model'] as String? ?? 'N/A',
      carColor: carDetails['color'] as String? ?? 'N/A',
      carPlateNumber: carDetails['plateNumber'] as String? ?? 'N/A',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      numberOfRatings: (json['numberOfRatings'] as num?)?.toInt() ?? 0,
      taxiOffice: json['taxiOffice'] as String? ?? 'Unknown Office',
      isAvailable: json['isAvailable'] ?? false,
      phone: userDetails?['phone'] ?? json['phone'] ?? 'N/A',
      email: userDetails?['email'] ?? json['email'] ?? 'N/A',
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
