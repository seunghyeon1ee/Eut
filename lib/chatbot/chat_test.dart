import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taba_app_proj/chatbot/greeting.dart';
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

import '../controller/fcm_controller.dart';

class ChatTest extends StatefulWidget {
  const ChatTest({super.key});

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
  String topEmotion = 'neutral';
  final Map<String, String> emotionImages = {
    '슬픔': 'assets/sad.png',
    '분노': 'assets/angry.png',
    '당황': 'assets/confused.png',
    '불안': 'assets/anxious.png',
    '행복': 'assets/happy.png',
    '중립': 'assets/neutral.png',
    '혐오': 'assets/disgusted.png',
  };

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
          'text':
              '독거노인에게 안부를 물어보는 말을 걸어줘. 날씨 얘기는 가급적 하지마', // todo 앱 시작 시 챗봇에게 시킬 프롬프트 작성 ex) 독거노인이 관심있을법한 대화주제로 말을 걸어줘
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

        /// todo 나중에 주석 해제
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
    // _toggleRecording();
  }

  @override
  void dispose() {
    _recorder.stopRecorder();
    _player.closeAudioSession();
    super.dispose();
  }

  // 원래 코드
  // void _toggleRecording() async {
  //  if (!_isRecording) {
  //    await _recorder.startRecorder(toFile: 'audio.mp4');
  //    print('녹음 시작');
  //  } else {
  //    await _recorder.stopRecorder();
  //    print('녹음 정지');
  //    textToSpeech(greetingMessage); // 녹음이 중지되면 TTS 실행
  //  }
  //  setState(() {
  //    _isRecording = !_isRecording;
  //    print('현재 $_isRecording');
  //  });
  // }

  /// 녹음 버튼 클릭
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

  /// 녹음 완료 후 stt api로 전송
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
          // 가장 높은 score의 label 추출
          topEmotion = result['result']['sentiment_analysis']
              .reduce((a, b) => a['score'] > b['score'] ? a : b)['label'];
          greetingMessage = result['result']['gpt_response'];
        });
        // _sttResult를 잠깐 보여줌
        showTemporaryMessage(_sttResult);
        // todo 감정 받는 변수 만들고 표정 변화 (result의 sentiment_analysis 중 score가 가장 높은 것을 temp 변수에 넣고 각 label에 맞는 표정으로 나타내기)
        // negativeRatio
        textToSpeech(
            greetingMessage); // Convert text to speech after transcription
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
      duration: const Duration(seconds: 2), // 메시지를 2초간 표시
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 챗봇의 응답을 음성으로 변환
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

  /// 오디오 파일 재생
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
    String imagePath =
        _isRecording ? 'assets/record_stop_icon.svg' : 'assets/record_icon.svg';
    String emotionImagePath = emotionImages[topEmotion] ??
        'assets/neutral.png'; // topEmotion에 따라 이미지 변경
    // final siricontroller = IOS7SiriWaveformController(
    //   amplitude: 0.8,
    //   color: Colors.redAccent,
    //   frequency: 10,
    //   speed: 0.25,
    // );
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                greetingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 80),
              // Row(
              //  mainAxisAlignment: MainAxisAlignment.center,
              //  children: [
              // Consumer<GreetingProvider> (
              //  builder: (context, provider, child) {
              //    return Text(provider.greeting,
              //      textAlign: TextAlign.center,
              //      style: TextStyle(color: Colors.black, fontSize: 30,
              //          fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.06),);
              //  },
              // ),
              // Text('안녕하세요',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(color: Colors.black, fontSize: 30,
              //       fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.06),
              // ),
              // ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RippleAnimation(
                    repeat: true,
                    color: Color(0xFFFF7672),
                    minRadius: 90,
                    ripplesCount: 6,
                    child: ClipOval(
                      child: Image.asset(
                          emotionImages[topEmotion] ?? 'assets/neutral.png',
                          width: 350,
                          height: 350,
                          fit: BoxFit.cover),
                    ),
                    // duration: const Duration(milliseconds: 6 * 300),
                    // delay: const Duration(milliseconds: 300),
                  ),
                ],
              ),

              // AvatarGlow(
              //   startDelay: const Duration(milliseconds: 1000),
              //   glowColor: Color(0xFFFF7672),
              //   glowShape: BoxShape.circle,
              //   curve: Curves.fastOutSlowIn,
              //   child: const Material(
              //     elevation: 0.0, // 그림자
              //     shape: CircleBorder(),
              //     color: Colors.transparent,
              //     child: CircleAvatar(
              //       backgroundColor: Colors.transparent,
              //       // child: SvgPicture.asset('assets/botboy.svg', height: 60),
              //       backgroundImage: AssetImage('assets/botboy_png.png'),
              //       radius: 100.0,
              //     ),
              //   ),
              // ),
              SizedBox(height: 50),

              // SizedBox(height: 50),
              // Text(_sttResult, style: TextStyle(fontSize: 20)),

              //       SiriWaveform.ios7(
              //         controller: siricontroller,
              //       options: IOS7SiriWaveformOptions(
              //       height: 100,
              //   width: 400,
              // ),
              //   ),

              // SizedBox(height: 70),
              // SvgPicture.asset('assets/record_icon.svg'),
            ],
          ),
        ),
        floatingActionButton: IconButton(
          icon: SvgPicture.asset(
            imagePath,
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
}
