import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _audioPath;

  List<Map<String, String>> drivers = [
    {'name': 'أحمد', 'image': 'https://via.placeholder.com/50'},
    {'name': 'محمد', 'image': 'https://via.placeholder.com/50'},
    {'name': 'سامي', 'image': 'https://via.placeholder.com/50'},
  ];
  String? selectedDriver;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
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
        messages.add({'type': 'audio', 'content': path});
      }
    });
  }

  Future<void> _playAudio(String path) async {
    await _player.startPlayer(fromURI: path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        messages.add({'type': 'image', 'content': pickedFile.path});
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'content': _controller.text});
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("الدردشة"),
        backgroundColor: Colors.yellow[700],
      ),
      body: Row(
        children: [
          if (isWeb) _buildDriversList(),
          Expanded(
            child: selectedDriver == null
                ? Center(child: Text("اختر سائقًا لبدء المحادثة", style: TextStyle(color: Colors.black)))
                : _buildChatUI(),
          ),
        ],
      ),
      drawer: !isWeb ? Drawer(child: _buildDriversList()) : null,
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
                backgroundImage: NetworkImage(driver['image']!),
              ),
              title: Text(driver['name']!, style: TextStyle(color: Colors.black)),
              onTap: () {
                setState(() {
                  selectedDriver = driver['name'];
                });
                if (!(MediaQuery.of(context).size.width > 600)) {
                  Navigator.pop(context); // إغلاق القائمة في الموبايل
                }
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
              final msg = messages[messages.length - 1 - index];
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: msg['type'] == 'text'
                      ? Text(msg['content'], style: TextStyle(color: Colors.black))
                      : msg['type'] == 'image'
                          ? Image.file(File(msg['content']), height: 150)
                          : IconButton(
                              icon: Icon(Icons.play_arrow, size: 30, color: Colors.blue),
                              onPressed: () => _playAudio(msg['content']),
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
            onPressed: _sendMessage,
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.red),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
    );
  }
}
