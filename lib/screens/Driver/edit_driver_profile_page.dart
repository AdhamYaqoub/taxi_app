import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDriverProfilePage extends StatefulWidget {
  final int driverId;
  const EditDriverProfilePage({super.key, required this.driverId});

  @override
  State<EditDriverProfilePage> createState() => _EditDriverProfilePageState();
}

class _EditDriverProfilePageState extends State<EditDriverProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController taxiOfficeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController profileImageUrlController = TextEditingController();

  bool isLoading = true;

 void loadDriverData() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['BASE_URL']}/api/drivers/${widget.driverId}'),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    setState(() {
      fullNameController.text = jsonData['user']['fullName'] ?? '';
      phoneController.text = jsonData['user']['phone'] ?? '';
      emailController.text = jsonData['user']['email'] ?? '';
      taxiOfficeController.text = jsonData['taxiOffice'] ?? '';
      modelController.text = jsonData['carDetails']['model'] ?? '';
      plateNumberController.text = jsonData['carDetails']['plateNumber'] ?? '';
      colorController.text = jsonData['carDetails']['color'] ?? '';
   

      isLoading = false;
    });
  } else {
    setState(() {
      isLoading = false;
    });
    print('Failed to load driver data. Status: ${response.statusCode}');
  }
}


  Future<void> saveProfile() async {
  if (_formKey.currentState!.validate()) {
    final updatedData = {
      "fullName": fullNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "taxiOffice": taxiOfficeController.text,
      "model": modelController.text,
      "plateNumber": plateNumberController.text,
      "color": colorController.text,
      "profileImageUrl": profileImageUrlController.text,
    };

    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/api/drivers/driver/${widget.driverId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ التعديلات بنجاح!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل حفظ التعديلات: ${response.reasonPhrase}")),
      );
    }
  }
}


  @override
  void initState() {
    super.initState();
    loadDriverData();
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(title: const Text("تعديل بيانات السائق")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: isWeb
                      ? Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            SizedBox(
                              width: 550,
                              child: buildCard("بيانات المستخدم", [
                                buildTextField(fullNameController, "الاسم الكامل"),
                                buildTextField(emailController, "البريد الإلكتروني"),
                                buildTextField(phoneController, "رقم الجوال"),
                              ]),
                            ),
                            SizedBox(
                              width: 550,
                              child: buildCard("بيانات السائق والسيارة", [
                                buildTextField(taxiOfficeController, "مكتب التاكسي"),
                                buildTextField(modelController, "موديل السيارة"),
                                buildTextField(plateNumberController, "رقم اللوحة"),
                                buildTextField(colorController, "لون السيارة"),
                                buildTextField(profileImageUrlController, "رابط صورة الملف"),
                              ]),
                            ),
                            SizedBox(
                              width: 1120,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    backgroundColor: Colors.green[700],
                                  ),
                                  icon: const Icon(Icons.save),
                                  label: const Text("حفظ التعديلات", style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            buildCard("بيانات المستخدم", [
                              buildTextField(fullNameController, "الاسم الكامل"),
                              buildTextField(emailController, "البريد الإلكتروني"),
                              buildTextField(phoneController, "رقم الجوال"),
                            ]),
                            buildCard("بيانات السائق والسيارة", [
                              buildTextField(taxiOfficeController, "مكتب التاكسي"),
                              buildTextField(modelController, "موديل السيارة"),
                              buildTextField(plateNumberController, "رقم اللوحة"),
                              buildTextField(colorController, "لون السيارة"),
                              buildTextField(profileImageUrlController, "رابط صورة الملف"),
                            ]),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: saveProfile,
                                icon: const Icon(Icons.save),
                                label: const Text("حفظ التعديلات"),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget buildCard(String title, List<Widget> fields) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }
}