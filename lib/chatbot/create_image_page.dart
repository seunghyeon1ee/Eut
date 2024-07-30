import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 패키지 임포트
import 'dart:async';
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../provider/create_image_provider.dart';
import '../provider/auth_provider.dart'; // AuthProvider 임포트
import 'image_item.dart';

class CreateImagePage extends StatefulWidget {
  final Function(ImageItem) onImageCreated;

  const CreateImagePage({Key? key, required this.onImageCreated}) : super(key: key);

  @override
  _CreateImagePageState createState() => _CreateImagePageState();
}

class _CreateImagePageState extends State<CreateImagePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    provider.setImagePath(0); // 초기 이미지 설정
    _loadToken(); // 토큰 로드
  }

  Future<void> _loadToken() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadToken();
  }

  void _saveImageItem() async {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (provider.selectedImagePath != null && _nameController.text.isNotEmpty && provider.recordingFilePath != null) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://3.38.165.93:8080/api/v1/character'),
        );
        request.headers['Content-Type'] = 'multipart/form-data';
        request.headers['Authorization'] = 'Bearer ${authProvider.accessToken}'; // 토큰 포함

        // Add characterName field
        request.fields['characterName'] = _nameController.text;
        request.fields['characterCode'] = _codeController.text;

        // Add voiceFile field
        final file = File(provider.recordingFilePath!);
        request.files.add(
          http.MultipartFile.fromBytes(
            'voiceFile',
            await file.readAsBytes(),
            filename: path.basename(file.path),
            contentType: MediaType('audio', 'mp3'),
          ),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Response body: $responseBody');

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final result = data['result'];
          final characterId = result['characterId'] as int;
          final memberId = result['memberId'] as int;
          final characterName = result['characterName'] as String;
          final voiceId = result['voiceId'] as String;

          widget.onImageCreated(
            ImageItem(
              name: characterName,
              characterId: characterId,
              memberId: memberId,
              characterName: characterName,
              voiceId: voiceId,
              imagePath: provider.selectedImagePath!,
              emotionImages: {}, // 초기화할 필요가 있다면 설정
            ),
          );
          Navigator.pop(context);
        } else {
          print('Response status: ${response.statusCode}');
          print('Response body: $responseBody');
          _showOverlayMessage(context, '서버 오류가 발생했습니다.');
        }
      } catch (e) {
        print('Exception: $e');
        _showOverlayMessage(context, '네트워크 오류가 발생했습니다.');
      }
    } else {
      _showOverlayMessage(context, '이미지와 이름, 음성 파일을 모두 입력해주세요.');
    }
  }

  void _showOverlayMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateImageProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
                  ),
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saveImageItem,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFEC295D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                '저장',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: provider.imagePaths.length,
                    controller: PageController(viewportFraction: 0.8),
                    onPageChanged: (index) {
                      provider.setImagePath(index);
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: PageController(viewportFraction: 0.8),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: index == provider.currentIndex ? 1.0 : 0.8,
                            child: child,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: provider.currentIndex == index
                                  ? Colors.transparent
                                  : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Image.asset(provider.imagePaths[index]),
                        ),
                      );
                    },
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: '이름을 입력해주세요.'),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(hintText: '코드를 입력해주세요.'),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16),
                VoiceRecordWidget(
                  onAudioFilePathUpdated: (filePath) {
                    provider.setRecordingFilePath(filePath);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class VoiceRecordWidget extends StatefulWidget {
  final ValueChanged<String> onAudioFilePathUpdated;

  const VoiceRecordWidget({Key? key, required this.onAudioFilePathUpdated}) : super(key: key);

  @override
  _VoiceRecordWidgetState createState() => _VoiceRecordWidgetState();
}

class _VoiceRecordWidgetState extends State<VoiceRecordWidget> {
  bool isRecording = false;
  bool isRecorded = false;
  int recordedTime = 0;
  late Timer timer;
  late String _recordingFilePath;

  void startRecording() {
    setState(() {
      isRecording = true;
      isRecorded = false;
      recordedTime = 0;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (recordedTime >= 30) {
        stopRecording();
      } else {
        setState(() {
          recordedTime++;
        });
      }
    });
  }

  void stopRecording() {
    timer.cancel();
    setState(() {
      isRecording = false;
      isRecorded = true;
    });
    _saveRecording();
  }

  void resetRecording() {
    setState(() {
      isRecording = false;
      isRecorded = false;
      recordedTime = 0;
    });
  }

  Future<void> _saveRecording() async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await file.writeAsBytes(List.generate(100, (index) => index)); // Mock data

    setState(() {
      _recordingFilePath = file.path;
    });

    widget.onAudioFilePathUpdated(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 파일이 저장되었습니다.: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '목소리 녹음',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isRecording || isRecorded ? Color(0xFFEC295D).withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '00:${recordedTime.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('취소', style: TextStyle(color: Color(0xFFEC295D), fontSize: 18)),
              ),
              if (isRecording)
                FloatingActionButton(
                  onPressed: stopRecording,
                  backgroundColor: Color(0xFFEC295D),
                  child: Icon(Icons.stop, size: 30, color: Colors.white,),
                ),
              if (!isRecording && !isRecorded)
                FloatingActionButton(
                  onPressed: startRecording,
                  backgroundColor: Color(0xFFEC295D),
                  child: Icon(Icons.mic, size: 30, color: Colors.white,),
                ),
              if (!isRecording && isRecorded)
                IconButton(
                  icon: Icon(Icons.refresh, color: Color(0xFFEC295D)),
                  onPressed: resetRecording,
                ),
              IconButton(
                icon: Icon(Icons.send, color: (isRecorded || isRecording) ? Color(0xFFEC295D) : Colors.grey),
                onPressed: () {
                  if (isRecorded) {
                    _saveRecording();
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
