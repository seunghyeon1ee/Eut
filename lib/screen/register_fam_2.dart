import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterFam2 extends StatefulWidget {
  const RegisterFam2 ({super.key});

  @override
  State<RegisterFam2> createState() => _RegisterFam2State();
}

class _RegisterFam2State extends State<RegisterFam2> {
  bool change = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('회원가입',
            style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Noto Sans', fontWeight: FontWeight.w400, height: 0.07),
          ),
          centerTitle: true,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),),
              Column(
                children: [
                  InkWell(
                    child: SvgPicture.asset(
                      'assets/back_button.svg',
                    ),
                    onTap: (){},
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              SvgPicture.asset('assets/icon_eut.svg', alignment: Alignment.topLeft),
              SizedBox(height: 80),
              Text('전화번호 인증하기', style: TextStyle(color: Colors.black, fontSize: 24, fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.06),
              ),
              SizedBox(height: 30.0),
              Text('입력하신 전화번호로 인증번호가 발송되었어요.',
                textAlign: TextAlign.left,
                style: TextStyle(color: Color(0xFF4D4D4D), fontSize: 14, fontFamily: 'Noto Sans', fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 86),
              Row(
                children: [
                  Container(
                    width: 195,
                    height: 52,
                    child: SingleChildScrollView(
                      child: TextField( // https://deku.posstree.com/ko/flutter/widget/textfield/
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          contentPadding: EdgeInsets.fromLTRB(18, 10, 20, 18),
                          labelText: '전화번호 입력',
                          labelStyle: TextStyle(color: Color(0xFF8F8F8F), fontSize: 18, fontFamily: 'Noto Sans',
                              fontWeight: FontWeight.w400, height: 0.07),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: (){},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(139, 52),
                      side: BorderSide(width: 1, color: Color(0xFFEC295D)),
                    ),
                    child: Text('인증번호 발송', style: TextStyle(color: Color(0xFFEC295D), fontSize: 18,
                        fontFamily: 'Noto Sans', fontWeight: FontWeight.w400, height: 0.07),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 209),
              TextButton(
                onPressed: () {
                  setState(() {
                    change = !change;
                  });
                },
                style: TextButton.styleFrom(
                  minimumSize: Size(350, 52),
                  backgroundColor: Color(0xFFE2E2E2),
                  foregroundColor: Color(0xFFEC295D),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(width: 1, color: Color(0xFFE2E2E2)),
                  ),
                ),
                child: Text('인증 완료', //selectionColor: change ? Color(0xFFE2E2E2) : Color(0xFFEC295D),
                  style: TextStyle(color: Color(0xFFAEAEAE), fontSize: 18,
                    fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.07),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}