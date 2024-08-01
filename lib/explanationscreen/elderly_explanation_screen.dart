// path: lib/screens/elderly_explanation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // svg 이미지 사용을 위한 패키지 추가

class ElderlyExplanationScreen extends StatelessWidget {
  const ElderlyExplanationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ' 앱 기능 상세 설명',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Noto Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 20),
                Text(
                  '* 챗봇과의 대화 방법',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1. 마이크 버튼을 누르고 말을 한다.\n '
                      '2. 할 말이 다 끝나면 중지 버튼을 누른다.\n'
                      '3. 챗봇이 말을 건네며, 사용자의 감정을 표정으로 나타낸다.\n ',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  '* 챗봇 설정하기',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1.대화 중이던 챗봇에서 캐릭터를 클릭한다.\n'
                      '2. 캐릭터 선택 : 목록 중에 원하는 캐릭터를 '
                      '선택하면 선택한 정보를 반영하여 챗봇 기능을 사용할 수 있다.'
                      '3. 캐릭터 생성 : 마지막에 위치한 +가 되어있는 회색 박스를 클릭한다.'
                      '나타나는 캐릭터와 이름을 선택하고 목소리를 녹음하여 저장한다.\n'
                      '4. 캐릭터 수정 : "수정하기" 선택한 후에 수정할 캐릭터에 나타난 연필 아이콘을 클릭한다.'
                      '캐릭터와 이름을 변경 가능하고, 녹음된 목소리를 들어보고 변경할 수 있다.\n'
                      ' 5. 캐릭터 삭제 : "수정하기"를 선택하고, 캐릭터 선택 박스들 오른쪽 위에 나타난 쓰레기통을 클릭한다.'
                  '삭제 확인 메시지에서 삭제를 선택한다.\n\n',
                  style: TextStyle(fontSize: 16),

                ),
                SizedBox(height: 20),
                Text(
                  ' ※ 단, 기본 캐릭터인 영수와 순옥이는 캐릭터 선택 외에 불가능하다.',
                style: TextStyle(fontSize: 16,
                color: Colors.pink),
                ),
                // Text(
                //   '서비스 사용 방법',
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 10),
                // Text(
                //   '1. 회원 가입 후 로그인을 합니다.\n'
                //       '2. 이웃들과 채팅을 시작합니다.\n'
                //       '3. 도움이 필요할 때는 도움 요청 버튼을 누릅니다.\n'
                //       '4. 공유된 정보를 확인하고 필요한 활동에 참여합니다.',
                //   style: TextStyle(fontSize: 16),
                // ),
                 SizedBox(height: 20),
                Text(
                  '* 고객 지원',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '서비스 이용 중 도움이 필요하시면 언제든지 \n031-***-****\n에 문의해주세요. '
                      '우리는 항상 여러분의 곁에 있습니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
