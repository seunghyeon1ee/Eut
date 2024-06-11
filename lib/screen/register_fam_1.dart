import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taba_app_proj/screen/register_fam_fin.dart';

import 'home_screen.dart';

class RegisFam extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterFam1(),
    );
  }
}

class RegisterFam1 extends StatefulWidget {
  const RegisterFam1 ({super.key});

  @override
  State<RegisterFam1> createState() => _RegisterFam1State();
}

class _RegisterFam1State extends State<RegisterFam1> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('회원가입',
            style: TextStyle(color: Colors.black,
                fontSize: 18,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w400,
                height: 0.07),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            highlightColor: Colors.white30,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SvgPicture.asset('assets/back_button.svg'),
            ),
          ),
        ),
        body: TextInputButton(),
      ),
    );
  }
}

class TextInputButton extends StatefulWidget {
  @override
  _TextInputButtonState createState() => _TextInputButtonState();
}

class _TextInputButtonState extends State<TextInputButton> {
  final TextEditingController _registerController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  Color _nextButtonColor = Color(0xFFE2E2E2);
  Color _nextTextColor = Color(0xFFAEAEAE);
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _registerController.addListener(_updateButtonColor);
    _numberController.addListener(_updateButtonColor);
    _registerController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
  }

  void _updateButtonColor() {
    bool isRegisterFilled = _registerController.text.isNotEmpty;
    bool isNumberFilled = _numberController.text.isNotEmpty;

    setState(() {
      if (isRegisterFilled && isNumberFilled) {
        _nextButtonColor = Color(0xFFEC295D);
        _nextTextColor = Colors.white;
      } else {
        _nextButtonColor = Color(0xFFE2E2E2);
        _nextTextColor = Color(0xFFAEAEAE);
      }
    });
  }

  void _updateButtonState() {
    bool isRegisterFilled = _registerController.text.isNotEmpty;
    bool isNumberFilled = _numberController.text.isNotEmpty;

    setState(() {
      _isButtonEnabled = isRegisterFilled && isNumberFilled;  // 두 필드 모두 채워져 있는지 확인
      if (_isButtonEnabled) {
        _nextButtonColor = Color(0xFFEC295D);
        _nextTextColor = Colors.white;
      } else {
        _nextButtonColor = Color(0xFFE2E2E2);
        _nextTextColor = Color(0xFFAEAEAE);
      }
    });
  }

  @override
  void dispose() {
    _registerController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Row(
              children: [
                SizedBox(width: 10),
                SvgPicture.asset('assets/icon_eut.svg'),
              ],
            ),
            Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
              Row(
                children: [
                  SizedBox(width: 10),
                  Text('회원정보 입력', style: TextStyle(color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      height: 0.06),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                children: [
                  SizedBox(width: 10),
                  Text('계정으로 사용되는 회원정보를 입력해주세요.',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Color(0xFF4D4D4D),
                        fontSize: 14,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 100),
              Row(
                children: [
                  SizedBox(width: 10),
                  _buildTextField(_registerController, '이메일'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 10),
                  _buildTextField(_numberController, '부모 전화번호'),
                ],
              ),
              SizedBox(height: 160),
              Row(
                children: [
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: _isButtonEnabled ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp3()),
                      );
                    } : null, // 버튼 활성화 여부에 따라 null을 반환하거나 함수를 실행
                    style: TextButton.styleFrom(
                      minimumSize: Size(350, 52),
                      backgroundColor: _nextButtonColor,
                      foregroundColor: _nextTextColor,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(width: 1, color: _nextButtonColor),
                      ),
                    ),
                    child: Text('다음', style: TextStyle(color: _nextTextColor,
                        fontSize: 18,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w600,
                        height: 0.07),
                    ),
                  ),
                ],
              ),
              ],
            ),
        ),
      ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController textFieldcontroller,
      String label) {
    return Container(
      width: 350,
      height: 52,
      child: TextField(
        controller: textFieldcontroller,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: EdgeInsets.fromLTRB(18, 10, 20, 18),
          labelText: label,
          labelStyle: TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 18,
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w400,
              height: 0.07
          ),
        ),
        keyboardType: TextInputType.text,
      ),
    );
  }
}

//             SizedBox(height: 100),
//             Container(
//             width: 350,
//             height: 52,
//
//             child: TextField( // https://deku.posstree.com/ko/flutter/widget/textfield/
//             controller: _registerController,
//             textAlign: TextAlign.left,
//             decoration: InputDecoration(
//             border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10))
//             ),
//             contentPadding: EdgeInsets.fromLTRB(18, 10, 20, 18),
//             labelText: '이메일',
//             labelStyle: TextStyle(color: Color(0xFF8F8F8F), fontSize: 18, fontFamily: 'Noto Sans',
//             fontWeight: FontWeight.w400, height: 0.07),
//             ),
//             keyboardType: TextInputType.phone,
//             ),
//             ),
//
//             SizedBox(height: 20),
//             Container(
//             width: 350,
//             height: 52,
//             child: SingleChildScrollView(
//             child: TextFormField( // https://deku.posstree.com/ko/flutter/widget/textfield/
//             controller: _numberController,
//             textAlign: TextAlign.left,
//             decoration: InputDecoration(
//             border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10))
//             ),
//             contentPadding: EdgeInsets.fromLTRB(18, 10, 20, 18),
//             labelText: '부모 전화번호',
//             labelStyle: TextStyle(color: Color(0xFF8F8F8F), fontSize: 18, fontFamily: 'Noto Sans',
//             fontWeight: FontWeight.w400, height: 0.07),
//             ),
//             keyboardType: TextInputType.phone,
//             ),
//             ),
//             ),
//           ],
//             ),
//           child: Column(
//               children: [
//                 SizedBox(height: 160),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => MyApp3()),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     minimumSize: Size(350, 52),
//                     backgroundColor: _nextButtonColor,
//                     foregroundColor: _nextTextColor,
//                     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(width: 1, color: _nextButtonColor),
//                     ),
//                   ),
//                   child: Text('다음', style: TextStyle(color: _nextTextColor, fontSize: 18,
//                       fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.07),
//                   ),
//                 ),
//               ],
//             ),
//         ),
//     );
//   }
// }
