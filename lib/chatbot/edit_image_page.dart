import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 패키지 임포트
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http_parser/http_parser.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../provider/create_image_provider.dart';
import 'image_item.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
// import 'package:waveform_flutter/waveform_flutter.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:just_waveform/just_waveform.dart';
import 'dart:ui' as ui;



class EditImagePage extends StatefulWidget {
  final List<ImageItem> imageItems;
  final int initialIndex;

  const EditImagePage({
    Key? key,
    required this.imageItems,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late String _name;
  late PageController _pageController;
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  late RecorderController _waveformController;
  bool _isWaveformInitialized = false;
  bool _isPlaying = false;
  // late AudioWaveforms _waveformController;
  // late Future<Waveform>? _waveform;


  @override
  void initState() {
    super.initState();
    // 초기화 시 제공된 인덱스와 아이템에 따라 이름 설정
    _name = widget.imageItems[widget.initialIndex].name;
    _pageController = PageController(initialPage: widget.initialIndex);
    _waveformController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    final provider = Provider.of<CreateImageProvider>(context, listen: false);

    provider.updateImagePath(widget.imageItems[provider.currentIndex].imagePath);
    provider.updateImagePaths(widget.imageItems.map((item) => item.imagePath).toList());

    // if (provider.recordingFilePath != null) {
    //   _waveform = _loadWaveform(provider.recordingFilePath!);
    // }
  }


  // Future<Waveform> _loadWaveform(String filePath) async {
  //   // final file = File(filePath);
  //   final waveform = await Waveform.fromFile(File(filePath));
  //   return waveform;
  // }

  // Future<Waveform> _loadWaveform(String filePath) async {
  //   final file = File(filePath);
  //   final waveform = await Waveform.fromFile(file);
  //   return waveform;
  // }


  void _editName() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: _name);
        return AlertDialog(
          title: Text('이름 수정'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "새 이름 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  final provider = Provider.of<CreateImageProvider>(context, listen: false);
                  widget.imageItems[provider.currentIndex] = widget.imageItems[provider.currentIndex].copyWith(name: _name);
                });
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _onImageChanged(int index) {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    provider.setImagePath(index);
    setState(() {
      widget.imageItems[provider.currentIndex] = widget.imageItems[provider.currentIndex].copyWith(imagePath: provider.selectedImagePath!);
    });
  }

  Future<void> _playAudio() async {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    if (provider.recordingFilePath != null) {
      if (_isPlaying) {
        await _audioPlayer.stopPlayer();
      } else {
        await _audioPlayer.startPlayer(
          fromURI: provider.recordingFilePath!,
          codec: Codec.mp3,
        );
        // 웨이브폼 초기화
        if (!_isWaveformInitialized) {
          setState(() {
            _isWaveformInitialized = true;
          });
        }
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } else {
      _showOverlayMessage(context, '재생할 오디오가 없습니다.');
    }
  }

  // Future<void> _playAudio() async {
  //   final provider = Provider.of<CreateImageProvider>(context, listen: false);
  //   if (provider.recordingFilePath != null) {
  //     if (_isPlaying) {
  //       await _audioPlayer.stopPlayer();
  //     } else {
  //       await _audioPlayer.startPlayer(
  //         fromURI: provider.recordingFilePath!,
  //         codec: Codec.mp3,
  //       );
  //     }
  //
  //     setState(() {
  //       _isPlaying = !_isPlaying;
  //     });
  //   } else {
  //     _showOverlayMessage(context, '재생할 오디오가 없습니다.');
  //   }
  // }

  // void _playAudio() async {
  //   final provider = Provider.of<CreateImageProvider>(context, listen: false);
  //   if (provider.recordingFilePath != null) {
  //     await _audioPlayer.startPlayer(fromURI: provider.recordingFilePath!, codec: Codec.mp3);
  //     // setState(() {
  //     //   _waveform = _loadWaveform(provider.recordingFilePath!);
  //     // });
  //   } else {
  //     _showOverlayMessage(context, '재생할 오디오가 없습니다.');
  //   }
  // }

  void _openVoiceRecordWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return VoiceRecordWidget(
          onAudioFilePathUpdated: (filePath) {
            final provider = Provider.of<CreateImageProvider>(context, listen: false);
            provider.setRecordingFilePath(filePath);
            setState(() {
              _waveformController.load(path: filePath);
            });
            // setState(() {
            //   // Update the waveform controller with the new file path
            //   _waveformController.load(path: filePath);
            // });
            // setState(() {
            //   _waveform = _loadWaveform(filePath);
            // });
          },
        );
      },
    );
  }

  Future<void> _submitEdit() async {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    if (_name.isNotEmpty && provider.recordingFilePath != null) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://3.38.165.93:8080/api/v1/character/{characterId}'), // API URL을 여기에 추가하세요
        );

        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields['characterName'] = _name;

        // Add voiceFile field if it exists
        if (provider.recordingFilePath != null) {
          final file = File(provider.recordingFilePath!);
          request.files.add(
            http.MultipartFile.fromBytes(
              'voiceFile',
              await file.readAsBytes(),
              filename: path.basename(file.path),
              contentType: MediaType('audio', 'mp3'),
            ),
          );
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final result = data['result'];
          final characterId = result['characterId'] as int;
          final memberId = result['memberId'] as int;
          final characterName = result['characterName'] as String;
          final voiceId = result['voiceId'] as String;

          // 이미지 아이템 업데이트
          setState(() {
            widget.imageItems[provider.currentIndex] = widget.imageItems[provider.currentIndex].copyWith(
              characterId: characterId,
              memberId: memberId,
              characterName: characterName,
              voiceId: voiceId,
              imagePath: provider.selectedImagePath!,
            );
          });

          Navigator.pop(context);
        } else {
          _showOverlayMessage(context, '서버 오류가 발생했습니다.');
        }
      } catch (e) {
        _showOverlayMessage(context, '네트워크 오류가 발생했습니다.');
      }
    } else {
      _showOverlayMessage(context, '이름과 음성 파일을 모두 입력해주세요.');
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
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '캐릭터 수정',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _submitEdit,
                  icon: Icon(Icons.check, color: Color(0xFFEC295D)),
                  label: Text('완료',
                    style: TextStyle(color: Color(0xFFEC295D),
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ScreenTypeLayout(
        mobile: _buildContent(provider),
        tablet: _buildContent(provider),
        desktop: _buildContent(provider),
        // body: ScreenTypeLayout(
        //   mobile: _buildContent(provider),
        //   tablet: _buildContent(provider),
        //   desktop: _buildContent(provider),
        // ),
      ),
    );
  }

  Widget _buildContent(CreateImageProvider provider) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: _buildImageSlider(provider)),
        _buildFixedControls(provider),
      ],
    );
  }


  Widget _buildImageSlider(CreateImageProvider provider) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onImageChanged,
      itemCount: provider.imagePaths.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100,),
            Center(
              child: Image.asset(
                provider.imagePaths[index],
                fit: BoxFit.cover,
                width: 250,
                height: 250,
              ),
            ),
          ],
        );
        Center(
          child: Image.asset(
            provider.imagePaths[index],
            fit: BoxFit.cover,
            width: 250,
            height: 250,
          ),
        );
      },
    );
  }

  Widget _buildFixedControls(CreateImageProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Expanded(
          //   child: PageView.builder(
          //     controller: _pageController,
          //     onPageChanged: _onImageChanged,
          //     itemCount: provider.imagePaths.length,
          //     itemBuilder: (context, index) {
          //       return Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //
          //           Image.asset(
          //             provider.imagePaths[index],
          //             fit: BoxFit.cover,
          //             width: 250,
          //             height: 250,
          //           ),
          //           SizedBox(height: 50),
          GestureDetector(
            onTap: _editName,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.edit, color: Colors.black, size: 20,),
                SizedBox(width: 8),
                Text('이름 : $_name', style: TextStyle(fontSize: 18,),
                ),
              ],
            ),
          ),
          SizedBox(height: 5,),
          Container(
            height: 1.5,
            color: Colors.black,
            width: 140,
          ),



          // SizedBox(height: 16),
          // provider.recordingFilePath != null
          //     ? FutureBuilder<Waveform>(
          //     future: _waveform,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(child: CircularProgressIndicator());
          //       }
          //       if (snapshot.hasError) {
          //         return Center(child: Text('오류 발생'));
          //       }
          //       final waveformData = snapshot.data;
          //       return Container(
          //         height: 100,
          //         child: Waveform(
          //           waveformData: waveformData!,
          //           color: Color(0xFFEC295D).withOpacity(0.1),
          //           waveColor: Color(0xFFEC295D),
          //         ),
          //       );
          //     },
          // )
          //    : Container(
          //  height: 100,
          //  color: Colors.grey[200],
          //  child: Center(child: Text('녹음된 오디오 없음')),
          // ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
          decoration: BoxDecoration(
          shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
                color: Color(0xFFEC295D), width: 1),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFEC295D).withOpacity(0.3), // 번짐 색상
                spreadRadius: 2, // 번짐 범위
                blurRadius: 5, // 번짐 강도
                offset: Offset(0, 2), // 번짐 위치
              ),
            ],
          ),
      child: IconButton(
          onPressed: _openVoiceRecordWidget,
          icon: Icon(Icons.mic,
            color: Color(0xFFEC295D),
            size: 30, // 아이콘 크기 조정
          ),
      ),
    ),
    SizedBox(width: 20),

          IconButton(
                icon: Icon(
                  provider.recordingFilePath != null ? Icons.play_circle_fill_outlined : Icons.play_disabled,
                  color: provider.recordingFilePath != null ? Color(0xFFEC295D) : Colors.grey,
                  size: 55,
                ),
                onPressed: _playAudio,
              ),
                SizedBox(width: 20),

              if (_isWaveformInitialized)
              Expanded(
                flex: 2,
                  child: AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width, 100.0),
                recorderController: _waveformController,
                enableGesture: true,
                waveStyle: WaveStyle(
                  waveColor: Color(0xFFEC295D),
                  showDurationLabel: true,
                  spacing: 5.0,
                  showBottom: false,
                  extendWaveform: true,
                  showMiddleLine: false,
                    gradient: ui.Gradient.linear(
                    const Offset(70, 50),
                    Offset(MediaQuery.of(context).size.width / 2, 0),
                    [Colors.red, Colors.green],
                  ),
                ),
              ),
              ),
              // Display waveform
              // Container(
              //   height: 100,
              //   child: AudioWaveforms(
              //     recorderController: _waveformController,
              //     waveStyle: WaveStyle(
              //       waveColor: Colors.blueAccent,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10),
              // // Play/Pause button
              // ElevatedButton(
              //   onPressed: _playAudio,
              //   child: Text(_isPlaying ? '중지' : '재생'),
              // ),

                  // ElevatedButton(
                  //   onPressed: _openVoiceRecordWidget,
                  //   child: Text('목소리 녹음',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 18,
                  //       ),),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xFFEC295D),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //     padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  //   ),
                  // ),
            ],
          ),
          SizedBox(height: 70,),
        ],

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
  // Waveform? _waveform;
  // late FlutterSoundRecorder _recorder;
  // String? _audioFilePath;

  // @override
  // void initState() {
  //   super.initState();
  //   _recorder = FlutterSoundRecorder();
  //   _openAudioSession();
  // }
  // Future<void> _openAudioSession() async {
  //   await _recorder.openAudioSession();
  // }
  //
  // @override
  // void dispose() {
  //   _recorder.closeAudioSession();
  //   // _waveformController.dispose();
  //   super.dispose();
  // }
  // late AudioWaveormsController _waveformController;
  // // final AudioWaveformController _waveformController = AudioWaveformController();
  // AudioWaveformController? _waveformController;


  // @override
  // void initState() {
  //   super.initState();
  //   _waveformController = WaveformController();
  // }

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

  // void startRecording() async {
  //   try {
  //     // Ensure the audio session is open
  //     if (!_recorder.isRecording) {
  //       await _openAudioSession();
  //     }
  //
  //     // Start recording
  //     await _recorder.startRecorder(
  //       toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
  //       codec: Codec.mp3,
  //     );
  //
  //     // Update UI state
  //     setState(() {
  //       isRecording = true;
  //       isRecorded = false;
  //       recordedTime = 0;
  //     });
  //
  //     // Timer for auto-stop
  //     timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //       if (recordedTime >= 30) { // Stop recording after 30 seconds
  //         stopRecording();
  //       } else {
  //         setState(() {
  //           recordedTime++;
  //         });
  //       }
  //     });
  //
  //   } catch (e) {
  //     print("Error starting recorder: $e");
  //     // Handle the error appropriately
  //   }
  // }

  // void startRecording() async {
  //   await _recordervoid startRecording() async {
  //     await _recorder.startRecorder(
  //       toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
  //       codec: Codec.mp3,
  //     );
  //     setState(() {
  //       isRecording = true;
  //       isRecorded = false;
  //       recordedTime = 0;
  //     });
  //     timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //       if (recordedTime >= 30) { // 30초 후 자동 정치
  //         stopRecording();
  //       } else {
  //         setState(() {
  //           recordedTime++;
  //         });
  //       }
  //     });
  //   }.startRecorder(
  //     toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
  //     codec: Codec.mp3,
  //   );
  //   setState(() {
  //     isRecording = true;
  //     isRecorded = false;
  //     recordedTime = 0;
  //   });
  //   timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (recordedTime >= 30) { // 30초 후 자동 정치
  //       stopRecording();
  //     } else {
  //       setState(() {
  //         recordedTime++;
  //       });
  //     }
  //   });
  // }

  // void stopRecording() async {
  //   _audioFilePath = await _recorder.stopRecorder();
  //   timer.cancel();
  //   setState(() {
  //     isRecording = false;
  //     isRecorded = true;
  //   });
  //   if (_audioFilePath != null) {
  //     widget.onAudioFilePathUpdated(_audioFilePath!);
  //   }
  //   await _saveRecording();
  // }
  //
  // void resetRecording() {
  //   setState(() {
  //     isRecording = false;
  //     isRecorded = false;
  //     recordedTime = 0;
  //   });
  // }

  Future<void> _saveRecording() async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav');
    await file.writeAsBytes(List.generate(100, (index) => index));
    setState(() {
      _recordingFilePath = file.path;
      // _waveform = Waveform.fromFile(file.path);
      // _waveform = await loadWaveformFromFile(file.path);
    });

    // await _waveformController.loadWaveform(file.path);

    widget.onAudioFilePathUpdated(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 파일이 저장되었습니다: ${file.path}')),
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
          // SizedBox(height: 20),
          // if (isRecorded)
          //   SizedBox(
          //     height: 100,
          //     child: Waveform(
          //       waveformData: _waveform!,
          //       color: Color(0xFFEC295D).withOpacity(0.1),
          //       waveColor: Color(0xFFEC295D),
          //   ),
          // controller: _waveform,
          // waveformType: WaveformType.live,
          // color: Color(0xFFEC295D).withOpacity(0.1),
          // ),
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
                  // 녹음 파일 저장 기능 추가
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