import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> drivers = [];
  List<Map<String, dynamic>> messages = [];
  String? selectedDriver;
  TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  Future<void> _loadDrivers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        drivers = data
            .where((driver) => driver['role'] == 'Driver')
            .map((driver) {
          return {
            'name': driver['fullName'],
            'image': driver['image'] ?? '',
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load drivers');
    }
  }

  Future<void> _loadMessages() async {
    if (selectedDriver != null) {
      final response = await http.get(Uri.parse('http://localhost:5000/messages?receiver=$selectedDriver'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load messages');
      }
    }
  }

  Future<void> _sendMessage(String message, {String? imagePath, String? audioPath}) async {
    if (message.isNotEmpty || imagePath != null || audioPath != null) {
      final response = await http.post(
        Uri.parse('http://localhost:5000/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': 'User',
          'receiver': selectedDriver,
          'message': message,
          'image': imagePath,
          'audio': audioPath,
        }),
      );
      if (response.statusCode == 201) {
        print('Message sent');
        _loadMessages();  // تحديث الرسائل بعد الإرسال
      } else {
        print('Failed to send message');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _sendMessage('', imagePath: pickedFile.path);
      });
    }
  }

  Future<void> _startRecording() async {
    setState(() => _isRecording = true);
    await _recorder.startRecorder(toFile: 'audio.aac');
    _audioPath = 'audio.aac';
  }

  Future<void> _stopRecording() async {
    String? path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      if (path != null) {
        _sendMessage('', audioPath: path);
      }
    });
  }

  Future<void> _playAudio(String path) async {
    await _player.startPlayer(fromURI: path);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.yellow[50],
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: Colors.yellow[700]),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.yellow[700]),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "اكتب رسالة...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.yellow[700]),
            onPressed: () {
              _sendMessage(_controller.text);
              _controller.clear();
            },
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.red),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    return Container(
      width: 250,
      color: Colors.yellow[100],
      child: ListView(
        children: [
          for (var driver in drivers)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: driver['image'] != ''
                    ? NetworkImage(driver['image'])
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              title: Text(driver['name'], style: TextStyle(color: Colors.black)),
              onTap: () {
                setState(() {
                  selectedDriver = driver['name'];
                  _loadMessages(); // تحميل الرسائل عند اختيار سائق
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    messages[index]['message'] ?? "No message",  // عرض الرسالة من قاعدة البيانات
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الدردشة"),
        backgroundColor: Colors.yellow[700],
      ),
      body: Row(
        children: [
          _buildDriversList(),
          Expanded(
            child: selectedDriver == null
                ? Center(child: Text("اختر سائقًا لبدء المحادثة", style: TextStyle(color: Colors.black)))
                : _buildChatUI(),
          ),
        ],
      ),
    );
  }
}
