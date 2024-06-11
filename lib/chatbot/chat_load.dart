import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class ChatLoad extends StatefulWidget {
  const ChatLoad ({super.key});

  @override
  State<ChatLoad> createState() => _ChatLoadState();
}

class _ChatLoadState extends State<ChatLoad> {
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
     _initRecorder();
   }

   Future<void> _initRecorder() async {
     final status = await Permission.microphone.request();
     if (status != PermissionStatus.granted) {
       throw RecordingPermissionException('Microphone permission not granted');
     }
     await _recorder.startRecorder();
   }

   @override
   void dispose() {
     _recorder.stopRecorder();
     super.dispose();
   }

  void _toggleRecording() async {
    if (!_isRecording) {
      // await _recorder.startRecorder(toFile: 'audio.mp4');
      print('녹음 시작');
    } else {
      // await _recorder.stopRecorder();
      print('녹음 정지');
    }
    setState(() {
      _isRecording = !_isRecording;
      print('현재 $_isRecording');
    });
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = _isRecording ? 'assets/record_stop_icon.svg' : 'assets/record_icon.svg';

    return SafeArea(
        child: Scaffold(
        body: Padding(
        padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  SizedBox(height: 110),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Text('안녕하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 30,
                      fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.06),
                      ),
                      ],
                      ),
                      SizedBox(height: 150),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/loading.gif', width: 250, height: 250, alignment: Alignment.center),
                        ],
                      ),
                SizedBox(height: 80),
                IconButton(
                  icon: SvgPicture.asset(imagePath, width: 110, height: 110,),
                  onPressed: _toggleRecording,
                  iconSize: 64.0,),
                    ],
              ),
        ),
        ),
    );
  }
}