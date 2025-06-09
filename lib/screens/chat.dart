import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:taxi_app/services/drivers_api.dart';
import 'package:taxi_app/services/taxi_office_api.dart';

String _idToString(dynamic id) {
  if (id == null) return '';
  if (id is String) return id;
  if (id is int) return id.toString();
  return id.toString();
}

class ChatScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String userType;
  final int? selectedDriverId;

  ChatScreen({
    required this.userId,
    required this.token,
    required this.userType,
    this.selectedDriverId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> messages = [];
  int? selectedContactId;
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

    if (widget.selectedDriverId != null) {
      selectedContactId = widget.selectedDriverId;
      _loadMessages();
    }
  }

  void _initSocket() {
    final String socketBaseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:5000';

    socket = IO.io(socketBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    if (widget.userType == 'User') {
      socket.emit('join_user', {'userId': widget.userId});
    } else if (widget.userType == 'Driver') {
      socket.emit('join_driver', {'driverId': widget.userId});
    } else if (widget.userType == 'Manager') {
      socket.emit('join_manager', {'managerId': widget.userId});
    }

    socket.on('new_message', (data) {
      if (_idToString(data['sender']) == _idToString(selectedContactId) ||
          _idToString(data['receiver']) == _idToString(selectedContactId)) {
        setState(() {
          messages.insert(0, {
            'sender': _idToString(data['sender']),
            'receiver': _idToString(data['receiver']),
            'message': data['message'],
            'image': data['image'],
            'audio': data['audio'],
            'timestamp': data['timestamp'],
            'read': data['read'],
          });
        });
      }
    });
  }

  Future<void> _loadContacts() async {
    try {
      if (widget.userType == 'Manager') {
        final drivers = await TaxiOfficeApi.getOfficeDrivers(widget.userId, widget.token);
        setState(() {
          contacts = drivers.map((driver) {
            return {
              'id': driver.driverUserId,
              'name': driver.fullName,
              'image': driver.profileImageUrl ?? '',
              'type': 'Driver',
              'officeId': driver.taxiOfficeId,
            };
          }).toList();
        });
      } else if (widget.userType == 'Driver') {
        final manager = await DriversApi.getDriverManagerForDriver(widget.userId, widget.token);
        if (manager != null) {
          setState(() {
            contacts = [
              {
                'id': manager.id,
                'name': manager.fullName,
                'image': manager.profileImageUrl ?? 'https://example.com/default.jpg',
                'type': 'Manager',
                'officeId': manager.officeId,
              }
            ];
            if (contacts.isNotEmpty) {
              selectedContactId = contacts.first['id'];
              _loadMessages();
            }
          });
        }
      }

      if (widget.selectedDriverId != null) {
        selectedContactId = widget.selectedDriverId;
        _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts: $e')),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (selectedContactId == null) return;
    try {
      final String apiBaseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:5000';
      final response = await http.get(
        Uri.parse('$apiBaseUrl/messages?user1=${_idToString(widget.userId)}&user2=${_idToString(selectedContactId)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          messages = data.map<Map<String, dynamic>>((msg) {
            return {
              'sender': _idToString(msg['sender']),
              'receiver': _idToString(msg['receiver']),
              'message': msg['message'],
              'image': msg['image'],
              'audio': msg['audio'],
              'timestamp': msg['timestamp'],
              'read': msg['read'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load conversation: $e')),
      );
    }
  }

  Future<void> _sendMessage(String message, {String? imagePath, String? audioPath}) async {
    if (message.isEmpty && imagePath == null && audioPath == null) return;
    if (selectedContactId == null) return;

    try {
      final contact = contacts.firstWhere((c) => c['id'] == selectedContactId);

      final newMessage = {
        'sender': _idToString(widget.userId),
        'receiver': _idToString(selectedContactId),
        'senderType': widget.userType,
        'receiverType': contact['type'],
        'message': message,
        'image': imagePath,
        'audio': audioPath,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
        'officeId': contact['officeId'],
      };

      setState(() {
        messages.insert(0, {
          'sender': _idToString(widget.userId),
          'receiver': _idToString(selectedContactId),
          'message': message,
          'image': imagePath,
          'audio': audioPath,
          'timestamp': DateTime.now().toIso8601String(),
          'read': false,
        });
      });

      socket.emit('new_message', newMessage);

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMessage),
      );

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TaxiGo Chat",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Color(0xFFFFC107),
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: widget.selectedDriverId != null
          ? _buildChatUI()
          : Row(
              children: [
                _buildContactsList(),
                Expanded(
                  child: selectedContactId == null
                      ? Center(
                          child: Text(
                            "اختر جهة اتصال لبدء المحادثة",
                            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        )
                      : _buildChatUI(),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      color: Color(0xFFF8F9FA),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: Color(0xFFFFC107), size: 28),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Color(0xFFFFC107), size: 28),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "اكتب رسالة...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFFFFC107), size: 28),
            onPressed: () => _sendMessage(_controller.text),
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : Color(0xFFFFC107),
              size: 28,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return Container(
      width: 280,
      color: Color(0xFF263238),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Text(
              "جهات الاتصال",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isSelected = contact['id'] == selectedContactId;

                return Container(
                  color: isSelected ? Color(0xFFFFC107) : Colors.transparent,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: contact['image'] != ''
                          ? NetworkImage(contact['image'])
                          : AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    title: Text(
                      contact['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      contact['type'],
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () {
                      setState(() {
                        selectedContactId = contact['id'];
                        _loadMessages();
                      });
                    },
                  ),
                );
              },
            ),
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
              final msg = messages[index];
              final isMe = msg['sender'] == _idToString(widget.userId);

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Color(0xFFFFC107) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg['message'] ?? '',
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _sendMessage('', imagePath: pickedFile.path);
    }
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    await _recorder.openRecorder();
    _audioPath = '/tmp/flutter_sound_example.aac';
    await _recorder.startRecorder(toFile: _audioPath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    setState(() {
      _isRecording = false;
    });
    if (_audioPath != null) {
      _sendMessage('', audioPath: _audioPath);
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }
}
