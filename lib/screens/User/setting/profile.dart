import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/client.dart';

class EditClientProfilePage extends StatefulWidget {
  final int clientId;
  const EditClientProfilePage({super.key, required this.clientId});

  @override
  State<EditClientProfilePage> createState() => _EditClientProfilePageState();
}

class _EditClientProfilePageState extends State<EditClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = true;
  bool isUploading = false;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    loadClientData();
  }

  Future<void> loadClientData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/clients/${widget.clientId}'),
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final clientData = json.decode(response.body);
        final client = Client.fromJson(clientData); // استخدم driverData هنا

        setState(() {
          fullNameController.text = client.fullName;
          phoneController.text = client.phone;
          emailController.text = client.email;
          _currentProfileImageUrl = client.profileImageUrl;
          isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل بيانات العميل');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
          '${dotenv.env['BASE_URL']}/api/clients/${widget.clientId}/profile-image');
      final request = http.MultipartRequest('PUT', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename: 'client_${widget.clientId}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody)['imageUrl'];
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isUploading = true);
    try {
      final newImageUrl = await uploadImage();
      final data = {
        'fullName': fullNameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        if (newImageUrl != null) 'profileImageUrl': newImageUrl,
      };

      final response = await http.put(
        Uri.parse('${dotenv.env['BASE_URL']}/api/clients/${widget.clientId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حفظ التغييرات بنجاح")),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('فشل في تحديث البيانات');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في الحفظ: ${e.toString()}")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Widget _buildProfileImage(BuildContext context) {
    final theme = Theme.of(context);
    ImageProvider? imageProvider;

    if (_selectedImageBytes != null) {
      imageProvider = MemoryImage(_selectedImageBytes!);
    } else if (_currentProfileImageUrl != null &&
        _currentProfileImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_currentProfileImageUrl!);
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person,
                      size: 50, color: theme.colorScheme.primary)
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelKey,
    required IconData icon,
    bool isRequired = true,
  }) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: local.translate(labelKey),
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: isRequired
            ? (value) =>
                value!.isEmpty ? local.translate('field_required') : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.translate('edit_profile')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? 20
                    : MediaQuery.of(context).size.width * 0.2,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileImage(context),
                    const SizedBox(height: 30),
                    _buildTextField(
                      context: context,
                      controller: fullNameController,
                      labelKey: 'full_name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context: context,
                      controller: phoneController,
                      labelKey: 'phone_number',
                      icon: Icons.phone_android_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context: context,
                      controller: emailController,
                      labelKey: 'email',
                      icon: Icons.email_outlined,
                      isRequired: false,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isUploading ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              local.translate('save_changes'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
