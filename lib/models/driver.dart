// models/driver.dart (ملف جديد)
class Driver {
  final int userId; // للربط مع نموذج المستخدم الأساسي إذا لزم الأمر
  // final String driverId; // أو معرف خاص بالسائق إذا كان مختلفاً
  final String fullName;
  final String? profileImageUrl; // قد تكون الصورة اختيارية
  final String carModel;
  final String carColor;
  final String carPlateNumber;
  final double rating;
  final int numberOfRatings;
  final bool isAvailable = true;
  final String taxiOffice;
  final String phone; // مكتب التاكسي إذا كان موجوداً
  // يمكنك إضافة حقول أخرى مثل taxiOffice، isAvailable الخ

  Driver(
      {required this.userId,
      required this.fullName,
      this.profileImageUrl,
      required this.carModel,
      required this.carColor,
      required this.carPlateNumber,
      required this.rating,
      required this.numberOfRatings,
      required this.taxiOffice,
      required this.phone});

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
      phone: userDetails?['phone'] ?? json['phone'] ?? 'N/A',
    );
  }
}
