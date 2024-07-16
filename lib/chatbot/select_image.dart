import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'chat1.dart';
import 'edit_image_page.dart';
import 'image_item.dart';
import 'create_image_page.dart';

class SelectImagePage extends StatefulWidget {
  @override
  _SelectImagePageState createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage> {
  List<ImageItem> imageItems = [
    ImageItem(imagePath: 'assets/botboy.png', name: '김영희'),
    ImageItem(imagePath: 'assets/image1.png', name: '김철수'),
  ];
  int? selectedIndex = 0;
  bool isEditing = false;

  void _onImageTap(int index) {
    if (!isEditing) {
      setState(() {
        selectedIndex = index;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RippleEffectPage(
            imagePath: imageItems[index].imagePath,
          ),
        ),
      );
    }
  }

  void _onEditIconTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImagePage(
          imageItems: imageItems,
          initialIndex: index,
        ),
      ),
    );
  }

  void _onAddButtonTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateImagePage(onImageCreated: (newImageItem) {
          setState(() {
            imageItems.add(newImageItem);
          });
        }),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return GestureDetector(
      onTap: () => _onImageTap(index),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isEditing
                  ? Colors.grey[200]
                  : (selectedIndex == index)
                  ? Colors.pink[50]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Opacity(
                opacity: isEditing ? 0.3 : 1.0,
                child: Image.asset(
                  imageItems[index].imagePath,
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          ),
          if (isEditing)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _onEditIconTap(index),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.edit,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          if (!isEditing && selectedIndex == index)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_circle,
                color: Colors.red,
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              imageItems[index].name,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 16),
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
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 50,
            color: Colors.grey,
          ),
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
                              builder: (context) => Chat1(),
                            ),
                          );
                        },
                        child: SvgPicture.asset('assets/icon_eut.svg', height: 80),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: Icon(isEditing ? Icons.check : Icons.edit),
                    label: Text(isEditing ? '완료' : '수정하기', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
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
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(
                  isEditing ? imageItems.length : imageItems.length + 1,
                      (index) {
                    if (index < imageItems.length) {
                      return _buildImageItem(index);
                    } else {
                      return _buildAddButton();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
