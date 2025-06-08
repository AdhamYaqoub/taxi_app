import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:taxi_app/services/taxi_office_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi App with Google Maps',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(userId: '', userType: '', selectedDriverId: null, officeId: null),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userType; // 'user', 'driver', 'office_manager', or 'admin'
  final String? selectedDriverId;
  final int? officeId; // Add officeId for office managers

  ChatScreen({
    required this.userId, 
    required this.userType,
    this.selectedDriverId,
    this.officeId,
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadContacts();
    _initAudio();
    
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

    if (widget.userType == 'office_manager') {
      socket.emit('join_office_manager', {
        'managerId': widget.userId,
        'officeId': widget.officeId
      });
    } else if (widget.userType == 'driver') {
      socket.emit('join_driver', {'driverId': widget.userId});
    }

    socket.on('new_message', (data) {
      if (mounted) {
        setState(() {
          messages.add({
            'senderId': data['senderId'],
            'senderType': data['senderType'],
            'message': data['message'],
            'timestamp': data['timestamp'],
          });
        });
      }
    });
  }

  Future<void> _loadContacts() async {
    try {
      setState(() => _isLoading = true);
      
      if (widget.userType == 'office_manager' && widget.officeId != null) {
        // Load only drivers from the same office
        final drivers = await TaxiOfficeApi.getOfficeDrivers(widget.officeId!, widget.userId);
        setState(() {
          contacts = drivers.map((driver) {
            return {
              'id': driver.driverUserId.toString(),
              'name': driver.fullName,
              'image': driver.profileImageUrl ?? '',
              'role': 'driver',
            };
          }).toList();
        });
      } else if (widget.userType == 'driver') {
        // Load only the office manager responsible for this driver
        final response = await http.get(
          Uri.parse('http://localhost:5000/api/drivers/${widget.userId}/manager'),
        );
        
        if (response.statusCode == 200) {
          final managerData = json.decode(response.body);
          setState(() {
            contacts = [{
              'id': managerData['id'].toString(),
              'name': managerData['fullName'],
              'image': managerData['profileImage'] ?? '',
              'role': 'office_manager',
              'officeId': managerData['officeId'],
            }];
            selectedContact = managerData['id'].toString();
            _loadMessages();
          });
        }
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (selectedContact != null) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:5000/messages?receiver=$selectedContact'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (mounted) {
            setState(() {
              messages = List<Map<String, dynamic>>.from(data);
            });
          }
        }
      } catch (e) {
        print('Error loading messages: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages')),
          );
        }
      }
    }
  }

  void _sendMessage(String message, {String? imagePath, String? audioPath}) {
    if (message.isNotEmpty || imagePath != null || audioPath != null) {
      final selectedContactData = contacts.firstWhere(
        (contact) => contact['id'] == selectedContact,
      );

      String eventName = widget.userType == 'office_manager' 
          ? 'office_manager_driver_message'
          : 'driver_office_manager_message';

      socket.emit(eventName, {
        'senderId': widget.userId,
        'receiverId': selectedContact,
        'message': message,
        'image': imagePath,
        'audio': audioPath,
        'officeId': widget.userType == 'office_manager' ? widget.officeId : selectedContactData['officeId'],
        'senderType': widget.userType,
        'receiverType': widget.userType == 'office_manager' ? 'driver' : 'office_manager',
      });

      // Save to database
      http.post(
        Uri.parse('http://localhost:5000/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': widget.userId,
          'receiver': selectedContact,
          'message': message,
          'image': imagePath,
          'audio': audioPath,
          'officeId': widget.userType == 'office_manager' ? widget.officeId : selectedContactData['officeId'],
          'senderType': widget.userType,
          'receiverType': widget.userType == 'office_manager' ? 'driver' : 'office_manager',
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
              selected: selectedContact == contact['id'],
              selectedTileColor: Colors.yellow[200],
              leading: CircleAvatar(
                backgroundImage: contact['image'] != ''
                    ? NetworkImage(contact['image'])
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              title: Text(
                contact['name'],
                style: TextStyle(
                  color: selectedContact == contact['id'] ? Colors.black : Colors.black87,
                  fontWeight: selectedContact == contact['id'] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                contact['role'],
                style: TextStyle(
                  color: selectedContact == contact['id'] ? Colors.black54 : Colors.grey,
                ),
              ),
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
    final selectedContactData = contacts.firstWhere(
      (contact) => contact['id'] == selectedContact,
      orElse: () => {'name': 'Unknown', 'image': ''},
    );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.yellow[50],
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: selectedContactData['image'] != ''
                    ? NetworkImage(selectedContactData['image'])
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              SizedBox(width: 12),
              Text(
                selectedContactData['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final isMe = messages[index]['senderId'] == widget.userId;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.yellow[200] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    messages[index]['message'] ?? "No message",
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("الدردشة"),
          backgroundColor: Colors.yellow[700],
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("الدردشة"),
        backgroundColor: Colors.yellow[700],
      ),
      body: widget.userType == 'driver'
          ? _buildChatUI() // For drivers, show chat directly with their manager
          : widget.selectedDriverId != null
              ? _buildChatUI()
              : Row(
                  children: [
                    _buildContactsList(),
                    Expanded(
                      child: selectedContact == null
                          ? Center(
                              child: Text(
                                "اختر جهة اتصال لبدء المحادثة",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
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
