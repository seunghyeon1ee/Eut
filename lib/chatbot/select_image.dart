import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'create_image_page.dart';
import 'edit_image_page.dart';
import 'chat_test.dart';
import 'image_item.dart';

class SelectImagePage extends StatefulWidget {
  @override
  _SelectImagePageState createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage> {
  List<ImageItem> imageItems = [
    ImageItem(
      imagePath: 'assets/neutral_girl.png',
      name: '김영희',
      emotionImages: {
        '슬픔': 'assets/sad_girl.png',
        '분노': 'assets/angry_girl.png',
        '당황': 'assets/confused_girl.png',
        '불안': 'assets/anxious_girl.png',
        '행복': 'assets/happy_girl.png',
        '중립': 'assets/neutral_girl.png',
        '혐오': 'assets/disgusted_girl.png',
      },
    ),
    ImageItem(
      imagePath: 'assets/neutral.png',
      name: '김철수',
      emotionImages: {
        '슬픔': 'assets/sad.png',
        '분노': 'assets/angry.png',
        '당황': 'assets/confused.png',
        '불안': 'assets/anxious.png',
        '행복': 'assets/happy.png',
        '중립': 'assets/neutral.png',
        '혐오': 'assets/disgusted.png',
      },
    ),
    // 기타 항목 추가
  ];

  int? selectedIndex;
  bool isEditing = false;

  void _onImageTap(int index) {
    if (isEditing) return;

    setState(() {
      selectedIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatTest(
          imagePath: imageItems[index].imagePath,
          emotionImages: imageItems[index].emotionImages,
        ),
      ),
    );
  }

  void _onEditIconTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImagePage(
          initialIndex: index,
          imageItems: imageItems,
        ),
      ),
    ).then((_) {
      // EditImagePage에서 돌아왔을 때 상태를 업데이트합니다.
      setState(() {});
    });
  }

  void _onAddButtonTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateImagePage(onImageCreated: (newImageItem) {
          setState(() {
            if (newImageItem is ImageItem) {
              imageItems.add(newImageItem);
            }
          });
        }),
      ),
    );
  }

  void _onDeleteIconTap(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  imageItems.removeAt(index);
                  if (selectedIndex == index) {
                    selectedIndex = imageItems.isNotEmpty ? (index > 0 ? index - 1 : null) : null;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageItem(int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onImageTap(index),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isEditing ? Colors.grey[200] : (isSelected ? Colors.pink[50] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Opacity(
                opacity: isEditing ? 0.3 : 1.0,
                child: imageItems[index].imagePath.endsWith('.svg')
                    ? SvgPicture.asset(imageItems[index].imagePath, width: 150, height: 150)
                    : Image.asset(imageItems[index].imagePath, width: 150, height: 150),
              ),
            ),
          ),
          if (isEditing) ...[
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _onDeleteIconTap(index),
                child: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _onEditIconTap(index),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Colors.red, size: 16),
                  ),
                ),
              ),
            ),
          ],
          if (!isEditing && isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: const Icon(Icons.check_circle, color: Colors.red),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              imageItems[index].name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _onAddButtonTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 50, color: Colors.grey),
        ),
      ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatTest(
                              ),
                            ),
                          );
                        },
                        child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      child: Text(
                        isEditing ? '완료' : '편집',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ResponsiveBuilder(
        builder: (context, size) {
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size.isDesktop ? 4 : (size.isTablet ? 3 : 2),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: imageItems.length + 1,
            itemBuilder: (context, index) {
              if (index == imageItems.length) {
                return _buildAddButton();
              }
              return _buildImageItem(index);
            },
          );
        },
      ),
    );
  }
}
