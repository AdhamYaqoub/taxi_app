import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:taxi_app/models/driver.dart';

class EditDriverProfilePage extends StatefulWidget {
  final int driverId;
  const EditDriverProfilePage({super.key, required this.driverId});

  @override
  State<EditDriverProfilePage> createState() => _EditDriverProfilePageState();
}

class _EditDriverProfilePageState extends State<EditDriverProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // عناصر التحكم في النموذج
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();

  bool isLoading = true;
  bool isUploading = false;

  String? _currentProfileImageUrl; // <--- متغير لتخزين رابط الصورة الحالي

  @override
  void initState() {
    super.initState();
    loadDriverData();
  }

  Future<void> loadDriverData() async {
    setState(() => isLoading = true); // أضفت هذه لضمان عرض المؤشر عند كل تحميل
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/drivers/${widget.driverId}'),
      );
      print('Response status: ${response.statusCode}'); // عدلت الطباعة
      print('Response body: ${response.body}'); // للتحقق من البيانات الواردة

      if (response.statusCode == 200) {
        final driverData = json.decode(response.body);
        final driver = Driver.fromJson(driverData); // استخدم driverData هنا
        setState(() {
          fullNameController.text = driver.fullName;
          phoneController.text = driver.phone;
          emailController.text = driver.email;
          carModelController.text = driver.carModel;
          carColorController.text = driver.carColor;
          plateNumberController.text = driver.carPlateNumber;
          licenseNumberController.text = driver.licenseNumber;
          licenseExpiryController.text =
              driver.licenseExpiry.toString().substring(0, 10);
          _currentProfileImageUrl =
              driver.profileImageUrl; // <--- تخزين رابط الصورة
          isLoading = false;
        });
      } else {
        // محاولة تحليل رسالة الخطأ من الباكند إذا كانت موجودة
        String errorMessage = 'Failed to load driver data';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {
          // فشل في تحليل رسالة الخطأ، استخدم الرسالة الافتراضية
        }
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        // تحقق من أن الويدجت ما زال في شجرة الويدجتس
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: ${e.toString()}')),
        );
      }
      print('Error loading driver data: $e'); // للتحقق من الخطأ في الكونسول
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _selectedImageBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة: ${e.toString()}')),
      );
    }
  }

  Future<String?> uploadImage() async {
    if (_selectedImageBytes == null) return null;

    try {
      final uri = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/drivers/${widget.driverId}/profile-image',
      );

      final request = http.MultipartRequest('PUT', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename:
            'driver_${widget.driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody)['imageUrl'];
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);

    try {
      // رفع الصورة أولاً إذا تم اختيارها
      String? newImageUrl = await uploadImage();

      // تحديث بيانات السائق
      final updatedData = {
        "fullName": fullNameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "carModel": carModelController.text,
        "carColor": carColorController.text,
        "carPlateNumber": plateNumberController.text,
        "licenseNumber": licenseNumberController.text,
        "licenseExpiry": licenseExpiryController.text,
        if (newImageUrl != null) "profileImageUrl": newImageUrl,
      };

      final response = await http.put(
        Uri.parse('${dotenv.env['BASE_URL']}/api/drivers/${widget.driverId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث البيانات بنجاح")),
        );
        Navigator.pop(context, true); // العودة مع تحديث البيانات
      } else {
        throw Exception('Failed to update profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في الحفظ: ${e.toString()}")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Widget _buildProfileImage() {
    final theme = Theme.of(context); // تصحيح اسم المتغير
    ImageProvider? backgroundImage;

    if (_selectedImageBytes != null) {
      backgroundImage = MemoryImage(_selectedImageBytes!);
    } else if (_currentProfileImageUrl != null &&
        _currentProfileImageUrl!.isNotEmpty) {
      // تأكد أن _currentProfileImageUrl هو URL كامل وصحيح
      print("Displaying network image: $_currentProfileImageUrl"); // للتحقق
      backgroundImage = NetworkImage(_currentProfileImageUrl!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor:
              theme.colorScheme.primary.withOpacity(0.7), // لون احتياطي
          backgroundImage: backgroundImage,
          onBackgroundImageError: backgroundImage
                  is NetworkImage // معالجة خطأ تحميل الصورة من الشبكة
              ? (exception, stackTrace) {
                  print("Error loading network image: $exception");
                  // يمكنك عرض أيقونة بديلة هنا إذا فشل تحميل الصورة
                  // setState(() { _currentProfileImageUrl = null; }); // لإجبار عرض الأيقونة
                }
              : null,
          child: (backgroundImage == null)
              ? Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        FloatingActionButton.small(
          onPressed: pickImage,
          backgroundColor: theme.primaryColor,
          child: const Icon(Icons.camera_alt, color: Colors.white),
          heroTag: null, // لمنع تعارض Hero tags إذا كان هناك أكثر من FAB
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
  }) {
    final theam = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theam.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theam.primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theam.primaryColor),
          ),
        ),
        validator: isRequired
            ? (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null
            : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    final theam = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: isUploading ? null : saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theam.primaryColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('حفظ التغييرات', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theam = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
        backgroundColor: theam.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: fullNameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person,
                    ),
                    _buildTextField(
                      controller: phoneController,
                      label: 'رقم الجوال',
                      icon: Icons.phone,
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email,
                    ),
                    _buildTextField(
                      controller: carModelController,
                      label: 'موديل السيارة',
                      icon: Icons.directions_car,
                    ),
                    _buildTextField(
                      controller: carColorController,
                      label: 'لون السيارة',
                      icon: Icons.color_lens,
                    ),
                    _buildTextField(
                      controller: plateNumberController,
                      label: 'رقم اللوحة',
                      icon: Icons.confirmation_number,
                    ),
                    _buildTextField(
                      controller: licenseNumberController,
                      label: 'رقم الرخصة',
                      icon: Icons.card_membership,
                    ),
                    _buildTextField(
                      controller: licenseExpiryController,
                      label: 'انتهاء الرخصة (YYYY-MM-DD)',
                      icon: Icons.calendar_today,
                    ),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }
}
