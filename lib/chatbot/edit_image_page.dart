import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'image_item.dart';  // Import the ImageItem class

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _name = widget.imageItems[_currentIndex].name;
    _pageController = PageController(initialPage: _currentIndex);
  }

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
                  widget.imageItems[_currentIndex].name = _name;
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
                  SizedBox(width: 10), // Add space to the right for balance
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 선택 PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _name = widget.imageItems[_currentIndex].name;
                  });
                },
                itemCount: widget.imageItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Image.asset(
                        widget.imageItems[index].imagePath,
                        width: 150,
                        height: 150,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _editName,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.black),
                  SizedBox(width: 8),
                  Text('이름: $_name', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return VoiceRecordWidget();
                  },
                );
              },
              child: Text('목소리 녹음'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
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
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.stop, size: 30),
                ),
              if (!isRecording && !isRecorded)
                FloatingActionButton(
                  onPressed: startRecording,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.mic, size: 30),
                ),
              if (!isRecording && isRecorded)
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.pinkAccent),
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
