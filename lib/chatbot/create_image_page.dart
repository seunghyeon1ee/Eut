import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // SVG 패키지 임포트
import 'dart:async';
import 'image_item.dart';
import 'package:responsive_builder/responsive_builder.dart';

// class EditImagePage extends StatefulWidget {
//   final List<ImageItem> imageItems;
//   final int initialIndex;
//
//   const EditImagePage({
//     Key? key,
//     required this.imageItems,
//     required this.initialIndex,
//   }) : super(key: key);
//
//   @override
//   _EditImagePageState createState() => _EditImagePageState();
// }
//
// class _EditImagePageState extends State<EditImagePage> {
//   late String _name;
//   late int _currentIndex;
//   late String _imagePath;
//   late PageController _pageController;
//   List<String> _imagePaths = [
//     'assets/botboy.png',
//     'assets/image1.png',
//     'assets/image2.png',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _name = widget.imageItems[_currentIndex].name;
//     _imagePath = widget.imageItems[_currentIndex].imagePath;
//     _pageController = PageController(initialPage: _imagePaths.indexOf(_imagePath));
//   }
//
//   void _editName() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController nameController = TextEditingController(text: _name);
//         return AlertDialog(
//           title: Text('이름 수정'),
//           content: TextField(
//             controller: nameController,
//             decoration: InputDecoration(hintText: "새 이름 입력"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('취소'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _name = nameController.text;
//                   widget.imageItems[_currentIndex].name = _name;
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: Text('저장'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _onImageChanged(int index) {
//     setState(() {
//       _imagePath = _imagePaths[index];
//       widget.imageItems[_currentIndex].imagePath = _imagePath;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(140.0),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           flexibleSpace: Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const SizedBox(width: 10),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 10), // 오른쪽 여백 추가
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: _onImageChanged,
//                 itemCount: _imagePaths.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 200,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       color: Colors.pink[50],
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: Center(
//                       child: Image.asset(
//                         _imagePaths[index],
//                         width: 150,
//                         height: 150,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             GestureDetector(
//               onTap: _editName,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.edit, color: Colors.black),
//                   SizedBox(width: 8),
//                   Text('이름: $_name', style: TextStyle(fontSize: 18)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   ),
//                   builder: (context) {
//                     return VoiceRecordWidget();
//                   },
//                 );
//               },
//               child: Text('목소리 녹음'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CreateImagePage extends StatefulWidget {
//   final Function(ImageItem) onImageCreated;
//
//   const CreateImagePage({Key? key, required this.onImageCreated}) : super(key: key);
//
//   @override
//   _CreateImagePageState createState() => _CreateImagePageState();
// }
//
// class _CreateImagePageState extends State<CreateImagePage> {
//   final TextEditingController _nameController = TextEditingController();
//   String? _selectedImagePath;
//   List<String> _imagePaths = [
//     'assets/botboy.png',
//     'assets/image1.png',
//     'assets/image2.png',
//   ];
//   int _currentIndex = 0;
//
//   void _saveImageItem() {
//     if (_selectedImagePath != null && _nameController.text.isNotEmpty) {
//       widget.onImageCreated(
//         ImageItem(imagePath: _selectedImagePath!, name: _nameController.text),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('이미지와 이름을 모두 입력해주세요.')),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedImagePath = _imagePaths[_currentIndex];
//   }
//
//   void _onImageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//       _selectedImagePath = _imagePaths[index];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(140.0),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           flexibleSpace: Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const SizedBox(width: 10),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: _saveImageItem,
//                     child: Row(
//                       children: [
//                         Icon(Icons.save, color: Colors.black),
//                         SizedBox(width: 5),
//                         Text(
//                           '저장',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 10), // 오른쪽 여백 추가
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 이미지 선택 PageView
//             Expanded(
//               child: PageView.builder(
//                 itemCount: _imagePaths.length,
//                 controller: PageController(viewportFraction: 0.8),
//                 onPageChanged: _onImageChanged,
//                 itemBuilder: (context, index) {
//                   return AnimatedBuilder(
//                     animation: PageController(viewportFraction: 0.8),
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: index == _currentIndex ? 1.0 : 0.8,
//                         child: child,
//                       );
//                     },
//                     child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 10.0),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: _currentIndex == index ? Colors.blue : Colors.transparent,
//                           width: 2.0,
//                         ),
//                       ),
//                       child: Image.asset(_imagePaths[index]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(hintText: '이미지 이름 입력'),
//             ),
//             SizedBox(height: 16),
//             VoiceRecordWidget(), // 목소리 녹음 위젯 추가
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class VoiceRecordWidget extends StatefulWidget {
//   @override
//   _VoiceRecordWidgetState createState() => _VoiceRecordWidgetState();
// }
//
// class _VoiceRecordWidgetState extends State<VoiceRecordWidget> {
//   bool isRecording = false;
//   bool isRecorded = false;
//   int recordedTime = 0;
//   late Timer timer;
//
//   void startRecording() {
//     setState(() {
//       isRecording = true;
//       isRecorded = false;
//       recordedTime = 0;
//     });
//     timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (recordedTime >= 30) {
//         stopRecording();
//       } else {
//         setState(() {
//           recordedTime++;
//         });
//       }
//     });
//   }
//
//   void stopRecording() {
//     timer.cancel();
//     setState(() {
//       isRecording = false;
//       isRecorded = true;
//     });
//   }
//
//   void resetRecording() {
//     setState(() {
//       isRecording = false;
//       isRecorded = false;
//       recordedTime = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.0),
//           topRight: Radius.circular(20.0),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '목소리 녹음',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 20),
//           Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: isRecording || isRecorded ? Colors.red[100] : Colors.grey[200],
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Text(
//                 '00:${recordedTime.toString().padLeft(2, '0')}',
//                 style: TextStyle(fontSize: 18, color: Colors.black),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('취소', style: TextStyle(color: Colors.red, fontSize: 18)),
//               ),
//               if (isRecording)
//                 FloatingActionButton(
//                   onPressed: stopRecording,
//                   backgroundColor: Colors.red,
//                   child: Icon(Icons.stop, size: 30),
//                 ),
//               if (!isRecording && !isRecorded)
//                 FloatingActionButton(
//                   onPressed: startRecording,
//                   backgroundColor: Colors.red,
//                   child: Icon(Icons.mic, size: 30),
//                 ),
//               if (!isRecording && isRecorded)
//                 IconButton(
//                   icon: Icon(Icons.refresh, color: Colors.red),
//                   onPressed: resetRecording,
//                 ),
//               IconButton(
//                 icon: Icon(Icons.send, color: (isRecorded || isRecording) ? Colors.red : Colors.grey),
//                 onPressed: () {
//                   // 녹음 파일 저장 기능 추가
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// 1. AppBar의 레이아웃과 디자인을 CreateImagePage와 일관되게 맞춤
// 2. VoiceRecordWidget을 양쪽 페이지에서 공통으로 사용하도록 구성
// 3. PageView.builder를 이용하여 이미지 선택 기능을 구현하고 PageController를 사용하여 페이지 전환 조정
// 4. VoiceRecordWidget의 버튼과 레이아웃을 조정




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
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            return Column(
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
                              color: _currentIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
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
            );
          },
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
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
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
                  color: isRecording || isRecorded ? Colors.red[100] : Colors
                      .grey[200],
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
                    child: Text('취소',
                        style: TextStyle(color: Colors.red, fontSize: 18)),
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
                    icon: Icon(Icons.send,
                        color: (isRecorded || isRecording) ? Colors.red : Colors
                            .grey),
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
      },
    );
  }
}
