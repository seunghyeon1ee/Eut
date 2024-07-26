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
import 'package:http_parser/http_parser.dart';
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
  _ChatTestState createState() => _ChatTestState();
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
  String topEmotion = 'neutral'; // 기본값으로 'neutral' 설정

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
    try {
      final response = await http.post(
        Uri.parse('http://54.180.229.143:8080/api/v1/chat/text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': '독거노인에게 안부를 물어보는 말을 걸어줘. 날씨 얘기는 가급적 하지마',
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['code'] == '0000' &&
            jsonResponse['message'] == 'SUCCESS') {
          setState(() {
            greetingMessage = jsonResponse['result']['response'];
          });
          textToSpeech(greetingMessage);
        } else {
          setState(() {
            greetingMessage = '환영 메시지 로드 실패';
          });
        }
      } else {
        setState(() {
          greetingMessage = '환영 메시지 로드 실패';
        });
      }
    } catch (e) {
      print('Greeting fetch error: $e');
      setState(() {
        greetingMessage = '환영 메시지 로드 실패';
      });
    }
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.openAudioSession();

      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('녹음 권한이 허용되지 않았습니다.');
      }
    } catch (e) {
      print('Recorder initialization error: $e');
    }
  }

  @override
  void dispose() {
    _recorder.closeAudioSession(); // Session 종료
    _player.closeAudioSession();
    super.dispose();
  }

  void _toggleRecording() async {
    try {
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
        if (path != null) {
          _sendAudioFileForTranscription(path);
        }
      }
    } catch (e) {
      print('Recording toggle error: $e');
    }
  }

  void _sendAudioFileForTranscription(String path) async {
    try {
      File audioFile = File(path);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      var request = http.MultipartRequest('POST', Uri.parse(_sttApiUrl))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        })
        ..files.add(await http.MultipartFile.fromPath(
            'voiceFile', audioFile.path,
            contentType: MediaType('audio', 'mp4')));

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = json.decode(utf8.decode(responseData));

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
        throw Exception('Speech generation failed');
      }
    } catch (e) {
      print('Text to Speech error: $e');
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
        print('Playback finished');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure widget.emotionImages is not null and has default values
    String emotionImagePath = widget.emotionImages.containsKey(topEmotion)
        ? widget.emotionImages[topEmotion]!
        : 'assets/neutral.png'; // Default image if key not found

    return SafeArea(
      child: Scaffold(
        body: ScreenTypeLayout.builder(
          mobile: (_) => buildContent(context),
          tablet: (_) => buildContent(context),
          desktop: (_) => buildContent(context, isDesktop: true),
        ),
        floatingActionButton: IconButton(
          icon: SvgPicture.asset(
            _isRecording ? 'assets/record_stop_icon.svg' : 'assets/record_icon.svg',
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

  Widget buildContent(BuildContext context, {bool isDesktop = false}) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          SizedBox(height: isDesktop ? 160 : 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RippleAnimation(
                repeat: true,
                color: Color(0xFFFF7672),
                minRadius: isDesktop ? 180 : 90,
                ripplesCount: 6,
                child: ClipOval(
                  child: Image.asset(
                    emotionImagePath,
                    width: isDesktop ? 700 : 350,
                    height: isDesktop ? 700 : 350,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 100 : 50),
        ],
      ),
    );
  }
}
