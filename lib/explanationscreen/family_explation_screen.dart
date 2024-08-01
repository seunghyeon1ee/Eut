// path: lib/screens/family_explanation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // svg 이미지 사용을 위한 패키지 추가

class FamilyExplanationScreen extends StatelessWidget {
  const FamilyExplanationScreen({Key? key}) : super(key: key);

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
                          '앱 기능 상세 설명',
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
                  '* 통계 화면',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1.오늘 : 당일 하루에 대한 통계를 나타낸다.\n '
                      '-대화내용 요약 : 대화내용을 오전과 오후로 나누어 대화한 내용들을 요약하여 나타낸다.\n  '
                      '-스크린 타임 : 하루에 대한 사용 시간을 시간대 별로 나누어 얼만큼 사용했는 지 나타낸다\n '
                      '-기분 확인 : 대화를 통해 나타난 감정들의 비율의 top3가 화면에 나타나고, "더 알아보기 >" '
                      '를 클릭해 상세한 비율을 알 수 있다. '
                    '2.이번주 : 최근 한 주에 대한 통계를 나타낸다.\n'
                    '-주간 감정 확인:가장 많이 나타난 감정을 나타내주며, 대화내용을 확인하세요를 '
                      '통해 주간 어떤 대화를 하였는 지 확인할 수 있다.\n'
                    '-사용 시간 비교 : 이번 주에 사용한 시간의 평균을 구하여, 지난 주와 비교해서 '
                      '사용 시간 증감의 정도를 알려준다.\n'
                    '-통계 그래프 : 오늘 날짜를 기준으로 최근 7일의 요일을 나타내어, 사용시간과 부정 표현 사용 비율을 나타낸다.\n',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  '*주요 기능',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1. 안부 확인: 정기적으로 독거노인의 상태를 확인한다.\n'
                      '2. 도움 요청: 요약된 대화를 통해서 부모의 정서를 파악할 수 있다.\n'
                  '3. 자료 시각화 : 시각화된 자료를 통해 노인의 상태를 빠르게 판단할 수 있다.\n',
                  //     '3. : 유용한 정보를 가족과 공유합니다.\n'
                  //     '4. 활동 추적: 독거노인의 활동을 추적하고 분석합니다.',
                   style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Text(
                //   '사용 방법',
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 10),
                // Text(
                //   '1. 앱을 설치하고 회원가입을 완료합니다.\n'
                //       '2. 가족 구성원을 추가하고 독거노인을 등록합니다.\n'
                //       '3. 정기적으로 앱을 사용하여 안부를 확인하고, 필요한 경우 도움을 요청합니다.\n'
                //       '4. 다양한 기능을 활용하여 가족과의 소통을 강화합니다.',
                //   style: TextStyle(fontSize: 16),
                // ),
                // SizedBox(height: 20),
                Text(
                  '고객 지원',
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
