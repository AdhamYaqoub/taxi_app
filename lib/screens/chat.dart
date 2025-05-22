import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi App with Google Maps',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(userId: '', userType: '', selectedDriverId: null),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userType; // 'user', 'driver', or 'admin'
  final String? selectedDriverId; // إضافة معرف السائق المحدد

  ChatScreen({
    required this.userId, 
    required this.userType,
    this.selectedDriverId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> messages = [];
  String? selectedContact;
  TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _audioPath;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadContacts();
    _initAudio();
    
    // إذا تم تحديد سائق، قم بتحديده تلقائياً
    if (widget.selectedDriverId != null) {
      selectedContact = widget.selectedDriverId;
      _loadMessages();
    }
  }

  void _initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // Join appropriate room based on user type
    if (widget.userType == 'user') {
      socket.emit('join_user', {'userId': widget.userId});
    } else if (widget.userType == 'driver') {
      socket.emit('join_driver', {'driverId': widget.userId});
    } else if (widget.userType == 'admin') {
      socket.emit('join_admin', {'adminId': widget.userId});
    }

    // Listen for new messages
    socket.on('new_message', (data) {
      setState(() {
        messages.add({
          'senderId': data['senderId'],
          'senderType': data['senderType'],
          'message': data['message'],
          'timestamp': data['timestamp'],
        });
      });
    });
  }

  Future<void> _loadContacts() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        contacts = data
            .where((contact) => contact['role'] != widget.userType)
            .map((contact) {
          return {
            'id': contact['_id'],
            'name': contact['fullName'],
            'image': contact['image'] ?? '',
            'role': contact['role'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<void> _loadMessages() async {
    if (selectedContact != null) {
      final response = await http.get(
        Uri.parse('http://localhost:5000/messages?receiver=$selectedContact'),
      );
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

  void _sendMessage(String message, {String? imagePath, String? audioPath}) {
    if (message.isNotEmpty || imagePath != null || audioPath != null) {
      final selectedContactData = contacts.firstWhere(
        (contact) => contact['id'] == selectedContact,
      );

      String eventName;
      if (widget.userType == 'user') {
        eventName = selectedContactData['role'] == 'Driver'
            ? 'user_driver_message'
            : 'user_admin_message';
      } else if (widget.userType == 'driver') {
        eventName = selectedContactData['role'] == 'User'
            ? 'user_driver_message'
            : 'driver_admin_message';
      } else {
        eventName = selectedContactData['role'] == 'User'
            ? 'user_admin_message'
            : 'driver_admin_message';
      }

      socket.emit(eventName, {
        'senderId': widget.userId,
        'receiverId': selectedContact,
        'message': message,
        'image': imagePath,
        'audio': audioPath,
      });

      // Also save to database
      http.post(
        Uri.parse('http://localhost:5000/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': widget.userId,
          'receiver': selectedContact,
          'message': message,
          'image': imagePath,
          'audio': audioPath,
        }),
      );

      _controller.clear();
    }
  }

  Future<void> _initAudio() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
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

  Widget _buildContactsList() {
    return Container(
      width: 250,
      color: Colors.yellow[100],
      child: ListView(
        children: [
          for (var contact in contacts)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: contact['image'] != ''
                    ? NetworkImage(contact['image'])
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              title: Text(contact['name'], style: TextStyle(color: Colors.black)),
              subtitle: Text(contact['role'], style: TextStyle(color: Colors.grey)),
              onTap: () {
                setState(() {
                  selectedContact = contact['id'];
                  _loadMessages();
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
      body: widget.selectedDriverId != null
          // إذا تم تمرير سائق محدد، اعرض فقط الدردشة معه
          ? _buildChatUI()
          // إذا لم يتم تمرير سائق، اعرض القائمة الجانبية
          : Row(
              children: [
                _buildContactsList(),
                Expanded(
                  child: selectedContact == null
                      ? Center(child: Text("اختر جهة اتصال لبدء المحادثة", style: TextStyle(color: Colors.black)))
                      : _buildChatUI(),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }
}
