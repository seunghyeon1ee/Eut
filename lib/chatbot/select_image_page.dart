import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taba_app_proj/model/character_model.dart';
import '../provider/auth_provider.dart';
import '../provider/create_image_provider.dart';
import 'create_image_page.dart';
import 'edit_image_page.dart';
import 'chat_test.dart';
import 'image_item.dart';

class SelectImagePage extends StatefulWidget {
  @override
  _SelectImagePageState createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage> {
  @override
  void initState() {
    super.initState();
    _fetchCharacterList();
  }

  Future<void> _fetchCharacterList() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    final response = await http.get(
        Uri.parse('http://3.38.165.93:8080/api/v1/character'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> characters = data['result'];

      Provider.of<CreateImageProvider>(context, listen: false).setImageItems(
        characters.map((character) {
          final characterId = character['characterId'] as int?;
          final memberId = character['memberId'] as int?;
          final characterName = character['characterName'] as String?;
          final voiceId = character['voiceId'] as String?;
          final characterCode = character['characterCode'] as String?;

          final CharacterModel characterModel = characterCode == 'boy'
              ? CharacterModel.boy()
              : CharacterModel.girl();

          final imagePath = characterModel.getEmotionImage(Emotion.neutral);

          final emotionImages = {
            '슬픔': characterModel.getEmotionImage(Emotion.sad),
            '분노': characterModel.getEmotionImage(Emotion.angry),
            '당황': characterModel.getEmotionImage(Emotion.confused),
            '불안': characterModel.getEmotionImage(Emotion.anxious),
            '행복': characterModel.getEmotionImage(Emotion.happy),
            '중립': characterModel.getEmotionImage(Emotion.neutral),
            '혐오': characterModel.getEmotionImage(Emotion.disgusted),
          };

          return ImageItem(
            name: characterName ?? '이름 없음',
            imagePath: imagePath,
            characterId: characterId,
            memberId: memberId,
            characterName: characterName,
            voiceId: voiceId,
            emotionImages: emotionImages,
          );
        }).toList(),
      );
    } else {
      throw Exception('Failed to load character list');
    }
  }

  Future<void> _deleteCharacter(int index) async {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    final characterId = provider.imageItems[index].characterId;
    if (characterId == null) {
      _showErrorMessage('삭제할 캐릭터의 ID가 없습니다.');
      return;
    }

    final response = await http.delete(
      Uri.parse('http://3.38.165.93:8080/character/$characterId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == '0000') {
        provider.removeImageItem(index);
      } else {
        _showErrorMessage('서버 오류: ${data['message']}');
      }
    } else {
      _showErrorMessage('삭제 요청 실패');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onImageTap(int index) {
    final provider = Provider.of<CreateImageProvider>(context, listen: false);
    if (provider.isEditing) return;

    provider.setSelectedIndex(index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatTest(
          imagePath: provider.imageItems[index].imagePath,
          emotionImages: provider.imageItems[index].emotionImages,
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
          imageItems: Provider.of<CreateImageProvider>(context, listen: false)
              .imageItems,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _onAddButtonTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateImagePage(onImageCreated: (newImageItem) {
          final provider =
          Provider.of<CreateImageProvider>(context, listen: false);
          provider.addImageItem(newImageItem);
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
                Navigator.of(context).pop();
                _deleteCharacter(index);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageItem(int index) {
    final provider = Provider.of<CreateImageProvider>(context);
    final isSelected = provider.selectedIndex == index;

    return GestureDetector(
      onTap: () => _onImageTap(index),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: provider.isEditing
                    ? Colors.grey[200]
                    : (isSelected ? Color(0xFFEC295D).withOpacity(0.1) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Opacity(
                  opacity: provider.isEditing ? 0.3 : 1.0,
                  child: provider.imageItems[index].imagePath.endsWith('.svg')
                      ? SvgPicture.asset(
                    provider.imageItems[index].imagePath,
                    fit: BoxFit.contain,
                  )
                      : Image.asset(
                    provider.imageItems[index].imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (provider.isEditing) ...[
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _onDeleteIconTap(index),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.delete, color: Color(0xFFEC295D), size: 20),
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
                      child: Icon(Icons.edit, color: Color(0xFFEC295D), size: 20),
                    ),
                  ),
                ),
              ),
            ],
            if (!provider.isEditing && isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: const Icon(Icons.check_circle, color: Color(0xFFEC295D)),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                provider.imageItems[index].characterName ?? '이름 없음',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _buildImageItem(int index) {
  //   final provider = Provider.of<CreateImageProvider>(context);
  //   final isSelected = provider.selectedIndex == index;
  //   return GestureDetector(
  //     onTap: () => _onImageTap(index),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Container(
  //         padding: const EdgeInsets.all(16.0),
  //         decoration: BoxDecoration(
  //             color: provider.isEditing
  //                 ? Colors.grey[200]
  //                 : (isSelected ? Color(0xFFEC295D).withOpacity(0.1) : Colors.grey[200]),
  //             borderRadius: BorderRadius.circular(8.0),
  //           ),
  //           // child: Column(
  //           //     mainAxisAlignment: MainAxisAlignment.center,
  //           //     children: [
  //           //         Container(
  //           //           width: 150, height: 150,
  //           //           decoration: BoxDecoration(
  //           //             color: Colors.grey[300],
  //           //             borderRadius: BorderRadius.circular(8.0),
  //           //           ),
  //                   child: Center(
  //                     child: Opacity(
  //                       opacity: provider.isEditing ? 0.3 : 1.0,
  //                       child: provider.imageItems[index].imagePath.endsWith('.svg')
  //                             ? SvgPicture.asset(provider.imageItems[index].imagePath,
  //                     // width: 150, height: 150,
  //                             fit: BoxFit.contain)
  //                             : Image.asset(provider.imageItems[index].imagePath,
  //                     // width: 150, height: 150,
  //                             fit: BoxFit.contain),
  //             ),
  //           ),
  //                   ),
  //                 const SizedBox(height: 8.0,),
  //                 Text(
  //                   provider.imageItems[index].characterName ?? '이름 없음',
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(color: Colors.black, fontSize: 16),
  //                 ),
  //           if (provider.isEditing) ...[
  //           Positioned(
  //             top: 8,
  //             right: 8,
  //             child: GestureDetector(
  //               onTap: () => _onDeleteIconTap(index),
  //               child: const CircleAvatar(
  //                 radius: 15,
  //                 backgroundColor: Colors.white,
  //                 child: Icon(Icons.delete, color: Color(0xFFEC295D), size: 20),
  //               ),
  //             ),
  //           ),
  //           if (provider.isEditing)
  //           Positioned.fill(
  //             child: Align(
  //               alignment: Alignment.center,
  //               child: GestureDetector(
  //                 onTap: () => _onEditIconTap(index),
  //                 child: const CircleAvatar(
  //                   radius: 20,
  //                    backgroundColor: Colors.white,
  //                   child: Icon(Icons.edit, color: Color(0xFFEC295D), size: 16),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //         if (!provider.isEditing && isSelected)
  //           Positioned(
  //             top: 8,
  //             right: 8,
  //             child: const Icon(Icons.check_circle, color: Color(0xFFEC295D),),
  //           ),
  //         // Positioned(
  //         //   bottom: 1,
  //         //   left: 8,
  //         //   right: 8,
  //         //   child: Text(
  //         //     provider.imageItems[index].characterName ?? '이름 없음',
  //         //     textAlign: TextAlign.center,
  //         //     style: const TextStyle(color: Colors.black, fontSize: 16),
  //       ],
  //     ),
  //   );
  //   //   ),
  //   // );
  // }

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
    final provider = Provider.of<CreateImageProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50, right: 16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatTest(
                                imagePath: 'assets/neutral.png',
                                emotionImages: {},
                              ),
                            ),
                          );
                        },
                        child:
                        SvgPicture.asset('assets/icon_eut.svg', height: 80),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: TextButton.icon(
                      icon: Icon(provider.isEditing ? Icons.check : Icons.edit,
                        color: provider.isEditing ? Colors.grey : Color(0xFFEC295D),
                      ),
                      label: Text(
                        provider.isEditing ? '완료' : '수정하기',
                        style: TextStyle(color: Colors.black,
                        fontSize: 20.0,),
                      ),
                      onPressed: () {
                        provider.toggleEditing();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
        child: ResponsiveBuilder(
          builder: (context, size) {
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size.isDesktop ? 4 : (size.isTablet ? 3 : 2),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: provider.imageItems.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.imageItems.length) {
                  return _buildAddButton();
                }
                return _buildImageItem(index);
              },
            );
          },
        ),
      ),
    );
  }
}