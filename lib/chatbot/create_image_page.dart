import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // SVG 패키지 임포트
import 'dart:async';
import 'image_item.dart';

class CreateImagePage extends StatefulWidget {
  final Function(ImageItem) onImageCreated;

  const CreateImagePage({Key? key, required this.onImageCreated}) : super(key: key);

  @override
  _CreateImagePageState createState() => _CreateImagePageState();
}

class _CreateImagePageState extends State<CreateImagePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedImagePath;
  List<String> _imagePaths = [
    'assets/botboy.png',
    'assets/image1.png',
    'assets/image2.png',
  ];
  int _currentIndex = 0;

  void _saveImageItem() {
    if (_selectedImagePath != null && _nameController.text.isNotEmpty) {
      widget.onImageCreated(
        ImageItem(imagePath: _selectedImagePath!, name: _nameController.text),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지와 이름을 모두 입력해주세요.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedImagePath = _imagePaths[_currentIndex];
  }

  void _onImageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _selectedImagePath = _imagePaths[index];
    });
  }

  @override
  Widget build(BuildContext context) {
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
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _saveImageItem,
                    child: Row(
                      children: [
                        Icon(Icons.save, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          '저장',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // 오른쪽 여백 추가
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지 선택 PageView
            Expanded(
              child: PageView.builder(
                itemCount: _imagePaths.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: _onImageChanged,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: PageController(viewportFraction: 0.8),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: index == _currentIndex ? 1.0 : 0.8,
                        child: child,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index ? Colors.blue : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Image.asset(_imagePaths[index]),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: '이미지 이름 입력'),
            ),
            SizedBox(height: 16),
            VoiceRecordWidget(), // 목소리 녹음 위젯 추가
          ],
        ),
      ),
    );
  }
}

class VoiceRecordWidget extends StatefulWidget {
  @override
  _VoiceRecordWidgetState createState() => _VoiceRecordWidgetState();
}

class _VoiceRecordWidgetState extends State<VoiceRecordWidget> {
  bool isRecording = false;
  bool isRecorded = false;
  int recordedTime = 0;
  late Timer timer;

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
  }

  void resetRecording() {
    setState(() {
      isRecording = false;
      isRecorded = false;
      recordedTime = 0;
    });
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
              color: isRecording || isRecorded ? Colors.red[100] : Colors.grey[200],
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
                child: Text('취소', style: TextStyle(color: Colors.red, fontSize: 18)),
              ),
              if (isRecording)
                FloatingActionButton(
                  onPressed: stopRecording,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.stop, size: 30),
                ),
              if (!isRecording && !isRecorded)
                FloatingActionButton(
                  onPressed: startRecording,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.mic, size: 30),
                ),
              if (!isRecording && isRecorded)
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.red),
                  onPressed: resetRecording,
                ),
              IconButton(
                icon: Icon(Icons.send, color: (isRecorded || isRecording) ? Colors.red : Colors.grey),
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
