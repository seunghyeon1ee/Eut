import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taba_app_proj/chatbot/greeting.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:taba_app_proj/chatbot/select_image.dart';

import '../controller/fcm_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';


class ChatTest extends StatefulWidget {
  final String imagePath;
  final Map<String, String> emotionImages;

  const ChatTest({
    Key? key,
    required this.imagePath,
    required this.emotionImages,
  }) : super(key: key);

  @override
  State<ChatTest> createState() => _ChatTestState();
}

class _ChatTestState extends State<ChatTest> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String greetingMessage = 'Loading...';
  String _sttResult = '녹음 버튼을 누르세요.';
  final String _sttApiUrl = 'http://54.180.229.143:8080/api/v1/chat/stt';
  final String _ttsApiUrl =
      'https://api.elevenlabs.io/v1/text-to-speech/VDHVV8QN47SSt26Po3BA';
  final String _apiKey = 'cef4d9cb6ac0ca3bf613183df847472c';
  String topEmotion = 'neutral'; // 감정을 나타내는 변수
  bool _useGirlImages = false; // 이미지 세트 선택 변수

  @override
  void initState() {
    super.initState();
    FcmController.instance.saveToken();
    _initRecorder();
    fetchGreeting();
    _player.openAudioSession();
  }

  Future<void> fetchGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(
        Uri.parse('http://54.180.229.143:8080/api/v1/chat/text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': '독거노인에게 안부를 물어보는 말을 걸어줘. 날씨 얘기는 가급적 하지마',
        }));
    print('response: ${utf8.decode(response.bodyBytes)}');
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
      if (jsonResponse['code'] == '0000' &&
          jsonResponse['message'] == 'SUCCESS') {
        setState(() {
          greetingMessage = jsonResponse['result']['response'];
        });

        textToSpeech(greetingMessage);
      }
    } else {
      setState(() {
        greetingMessage = '환영 메시지 로드 실패';
      });
    }
  }

  Future<void> _initRecorder() async {
    await _recorder.openAudioSession();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('녹음 권한 허용되지 않음');
    }
  }

  @override
  void dispose() {
    _recorder.stopRecorder();
    _player.closeAudioSession();
    super.dispose();
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      await _recorder.startRecorder(
        toFile: 'why.mp4',
        codec: Codec.aacMP4,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      _sendAudioFileForTranscription(path!);
    }
  }

  void _sendAudioFileForTranscription(String path) async {
    print('Sending audio file for transcription...');
    print('path: $path');
    File audioFile = File(path);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_sttApiUrl))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        })
        ..files.add(await http.MultipartFile.fromPath(
            'voiceFile', audioFile.path,
            contentType: MediaType('audio', 'mp3')));
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = json.decode(utf8.decode(responseData));
      print(result);
      if (response.statusCode == 200) {
        setState(() {
          _sttResult = result['result']['stt_result'];
          topEmotion = result['result']['sentiment_analysis']
              .reduce((a, b) => a['score'] > b['score'] ? a : b)['label'];
          greetingMessage = result['result']['gpt_response'];
        });
        showTemporaryMessage(_sttResult);
        textToSpeech(greetingMessage);
      } else {
        setState(() {
          _sttResult = 'STT 작동 중 에러 발생';
        });
      }
    } catch (e) {
      setState(() {
        _sttResult = 'Error sending audio file: $e';
      });
    }
  }

  void showTemporaryMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> textToSpeech(String text) async {
    try {
      var response = await http.post(
        Uri.parse(_ttsApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
        }),
      );

      if (response.statusCode == 200) {
        String filePath = await _saveFile(response.bodyBytes);
        _playAudio(filePath);
      } else {
        throw Exception('speech 생성 실패');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<String> _saveFile(List<int> fileBytes) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/tts_output.mp3';
    File file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return filePath;
  }

  void _playAudio(String filePath) {
    _player.startPlayer(
      fromURI: filePath,
      whenFinished: () {
        print('재생 완료');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String recordImagePath =
    _isRecording ? 'assets/record_stop_icon.svg' : 'assets/record_icon.svg';
    Map<String, String> currentEmotionImages = widget.emotionImages;
    String emotionImagePath = currentEmotionImages[topEmotion] ?? 'assets/neutral.png';
    return SafeArea(
      child: Scaffold(
        body: ScreenTypeLayout.builder(
          mobile: (_) => buildContent(context, emotionImagePath),
          tablet: (_) => buildContent(context, emotionImagePath),
          desktop: (_) => buildContent(context, emotionImagePath, isDesktop: true),
        ),
        floatingActionButton: IconButton(
          icon: SvgPicture.asset(
            recordImagePath,
            width: 110,
            height: 110,
          ),
          onPressed: _toggleRecording,
          iconSize: 64.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget buildContent(BuildContext context, String emotionImagePath, {bool isDesktop = false}) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: isDesktop ? 80 : 40),
          Text(
            greetingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: isDesktop ? 28 : 22,
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isDesktop ? 80 : 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectImagePage()),
              );
            },
            child: Image.asset(
              emotionImagePath,
              width: isDesktop ? 300 : 200,
              height: isDesktop ? 300 : 200,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '현재 감정: $topEmotion',
            style: TextStyle(
              color: Colors.black,
              fontSize: isDesktop ? 24 : 18,
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
