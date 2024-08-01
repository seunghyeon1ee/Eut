import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:taba_app_proj/chatbot/chat_test.dart';
import 'package:taba_app_proj/screen/home_screen.dart';

import '../explanationscreen/elderly_explanation_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;
  kakao_user.KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LogInElder2();
  }
}

class LogInElder2 extends StatefulWidget {
  const LogInElder2({super.key});

  @override
  State<LogInElder2> createState() => _LogInElder2State();
}

class _LogInElder2State extends State<LogInElder2> {
  final _phoneController = TextEditingController();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '시작하기',
            style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w400,
                height: 0.07),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            highlightColor: Colors.white30,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: SvgPicture.asset('assets/back_button.svg'),
            ),
          ),
        ),
        body: VerificationWidget(),
      ),
    );
  }
}

// 전화번호 인증 위젯
class VerificationWidget extends StatefulWidget {
  const VerificationWidget({super.key});

  @override
  _VerificationWidgetState createState() => _VerificationWidgetState();
}

class _VerificationWidgetState extends State<VerificationWidget> {
  bool _isTextFieldVisible = false;
  String _buttonText = '인증번호 발송';

  final TextEditingController _controller = TextEditingController(); // 전화번호 입력 컨트롤러
  final TextEditingController _confirmController = TextEditingController(); // 인증번호 입력 컨트롤러
  Color _buttonColor = Color(0xFFE2E2E2);
  Color _buttonConfirmColor = Color(0xFFE2E2E2);
  Color _textColor = Color(0xFFAEAEAE);
  Color _textConfirmColor = Color(0xFFAEAEAE);

  late String _verificationId;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  Timer? _timer;
  int _remainingTime = 300; // 5분 = 300초

  void sendCode() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+82${_controller.text}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        print("verificationFailed error.code: ${e.code}");
        String errorMessage;
        switch (e.code) {
          case "invalid-phone-number":
            errorMessage = "휴대폰 번호의 형식이 잘못되었습니다";
            break;
          case "too-many-requests":
            errorMessage = "요청이 너무 많습니다. 잠시 후 다시 시도하세요";
            break;
          case "web-context-cancelled":
            errorMessage = "인증 화면이 종료되었습니다. 다시 시도하세요";
            break;
          case "quota-exceeded":
            errorMessage = "인증 할당량이 초과되었습니다";
            break;
          case "internal-error":
            errorMessage = "잘못된 요청입니다";
            break;
          default:
            errorMessage = "알 수 없는 오류가 발생했습니다";
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('휴대전화 인증 실패: $errorMessage')));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('인증번호 발송')));
        startTimer();
        setState(() {
          _isTextFieldVisible = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _toggleTextField() {
    if (_controller.text.length == 11 &&
        _controller.text.runes.every((r) => r >= '0'.runes.first && r <= '9'.runes.first)) {
      setState(() {
        _buttonColor = Color(0xFFEC295D);
        _textColor = Color(0xFFEC295D);

        _buttonText = _isTextFieldVisible ? "재발송" : "인증번호 발송";
      });
    } else {
      setState(() {
        _buttonColor = Color(0xFFE2E2E2);
        _textColor = Color(0xFFAEAEAE);
      });
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("인증번호 유효시간이 만료되었습니다. 다시 시도해주세요.")));
        setState(() {
          _isTextFieldVisible = false;
          _remainingTime = 300;
        });
      }
    });
  }

  String get timerText {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleTextFieldConfirm() {
    if (_confirmController.text.length == 6 &&
        _confirmController.text.runes.every((r) => r >= '0'.runes.first && r <= '9'.runes.first)) {
      setState(() {
        _buttonConfirmColor = Color(0xFFEC295D);
        _textConfirmColor = Colors.white;
      });
    } else {
      setState(() {
        _buttonConfirmColor = Color(0xFFE2E2E2);
        _textConfirmColor = Color(0xFFAEAEAE);
      });
    }
  }

  Future<bool> registerParent(String phone) async {
    var url = Uri.parse('http://3.38.165.93:8080/api/v1/join');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'phone': phone, 'type': 'P'}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedJson['message'] == 'SUCCESS') {
        bool loginResult = await loginUser(phone);
        return loginResult;
      } else {
        print('회원가입은 성공했지만, 예상치 못한 응답 메시지입니다: ${decodedJson['message']}');
      }
    } else if (response.statusCode == 400) {
      Map<String, dynamic> errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (errorResponse['message'].toString().contains('이미 존재하는 유저입니다')) {
        bool loginResult = await loginUser(phone);
        if (loginResult) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> loginUser(String phone) async {
    var url = Uri.parse('http://3.38.165.93:8080/api/v1/login');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      await saveUserData(response.body);

      return true;
    }
    return false;
  }

  Future<bool> saveUserData(String jsonResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final responseData = jsonDecode(jsonResponse);

    if (responseData['code'] == "0000" && responseData['message'] == "SUCCESS") {
      String accessToken = responseData['result']['access_token'];
      String refreshToken = responseData['result']['refresh_token'];
      String phone = responseData['result']['phone'];
      String memberType = responseData['result']['memberType'];

      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('phone', phone);
      await prefs.setString('member_type', memberType);

      return true;
    }
    return false;
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');
    String? phone = prefs.getString('phone');
    String? memberType = prefs.getString('member_type');

    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');
    print('Phone: $phone');
    print('Member Type: $memberType');
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_toggleTextField);
    _confirmController.addListener(_toggleTextFieldConfirm);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loginWithKakao() async {
    try {
      bool isKakaoTalkInstalled = await kakao_user.isKakaoTalkInstalled();
      kakao_user.OAuthToken token;
      if (isKakaoTalkInstalled) {
        token = await kakao_user.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
      }

      print('Kakao login success: ${token.accessToken}');
      // 실제 전화번호를 가져오는 로직을 추가해야 합니다.
      final userPhoneNumber = '01012345678'; // 예시 전화번호, 실제 로직 필요
      final email = 'user@example.com'; // Kakao에서 이메일을 가져오는 방법 추가 필요

      bool registrationResult = await registerParent(userPhoneNumber);
      if (registrationResult) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatTest(
                  imagePath: 'assets/sample.png',
                  emotionImages: {},
                )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원가입 실패, 다시 시도해주세요")));
      }
    } catch (e) {
      print('Kakao login error: $e');
    }
  }

  Future<void> _loginWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.loggedIn) {
        final token = result.accessToken;
        final email = result.account.email; // Naver에서 제공하는 이메일
        // Naver 로그인 후 사용자 정보를 가져오는 추가 작업이 필요할 수 있습니다.
        final userPhoneNumber = '01012345678'; // 실제 전화번호를 가져오는 로직을 추가해야 합니다.

        bool registrationResult = await registerParent(userPhoneNumber);
        if (registrationResult) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatTest(
                    imagePath: 'assets/sample.png',
                    emotionImages: {},
                  )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("회원가입 실패, 다시 시도해주세요")));
        }
      }
    } catch (e) {
      print('Naver login error: $e');
    }
  }

  Future<void> _loginWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final firebase_auth.OAuthCredential credential =
      firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null && user.phoneNumber != null) {
        String email = appleCredential.email ?? 'user@example.com';
        String parentPhone = 'parentPhoneNumber'; // replace with actual logic
        bool registrationResult = await registerParent(user.phoneNumber!);
        if (registrationResult) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatTest(
                    imagePath: 'assets/sample.png',
                    emotionImages: {},
                  )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("회원가입 실패, 다시 시도해주세요")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("인증 실패: 사용자 정보가 없습니다.")));
      }
    } catch (e) {
      print('Apple login error: $e');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
        final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null && user.phoneNumber != null) {
          String parentPhone = googleUser.email;
         // String parentPhone = 'parentPhoneNumber'; // replace with actual logic
          bool registrationResult = await registerParent(user.phoneNumber!);
          if (registrationResult) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatTest(
                      imagePath: 'assets/sample.png',
                      emotionImages: {},
                    )));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("회원가입 실패, 다시 시도해주세요")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("인증 실패: 사용자 정보가 없습니다.")));
        }
      }
    } catch (e) {
      print('Google login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ScreenTypeLayout(
      mobile: _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: screenSize.width * 0.03,),
              SvgPicture.asset('assets/icon_eut.svg', width: screenSize.width * 0.2,),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ElderlyExplanationScreen()), // Update here
                  );
                },
              //  child: SvgPicture.asset('assets/icon_eut.svg'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.1),
                Row(
                  children: [
                    SizedBox(width: screenSize.width * 0.02),
                    Text('환영합니다!',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: screenSize.width * 0.07,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w600,
                            height: 0.06)),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.05),
                Row(
                  children: [
                    SizedBox(width: screenSize.width * 0.03),
                    Text('이웃이 있으면 가깝고, 웃음이 있으면 밝고\n이웃을 지금 시작해보세요!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0xFF4D4D4D),
                            fontSize: 14,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.07),
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: screenSize.width * 0.03),
                        Container(
                          width: 195,
                          height: 52,
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              contentPadding:
                              EdgeInsets.fromLTRB(18, 10, 20, 18),
                              labelText: '전화번호 입력',
                              labelStyle: TextStyle(
                                  color: Color(0xFF8F8F8F),
                                  fontSize: 18,
                                  fontFamily: 'Noto Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0.07),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            if (_controller.text.length == 11 &&
                                _controller.text.runes.every((r) =>
                                r >= '0'.runes.first &&
                                    r <= '9'.runes.first)) {
                              setState(() {
                                _isTextFieldVisible = !_isTextFieldVisible;
                                _buttonText = "재발송";
                              });
                              sendCode();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size(139, 52),
                            side: BorderSide(width: 1, color: _buttonColor),
                          ),
                          child: Text(_buttonText,
                              style: TextStyle(
                                  color: _textColor,
                                  fontSize: 18,
                                  fontFamily: 'Noto Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0.07)),
                        ),
                      ],
                    ),
                    if (_isTextFieldVisible) SizedBox(height: 10),
                    if (_isTextFieldVisible)
                      Column(
                        children: [
                          SizedBox(height: 15),
                          Container(
                              width: 350,
                              height: 52,
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _confirmController,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      contentPadding:
                                      EdgeInsets.fromLTRB(16, 10, 20, 16),
                                      labelText: '인증번호',
                                      labelStyle: TextStyle(
                                          color: Color(0xFF8F8F8F),
                                          fontSize: 18,
                                          fontFamily: 'Noto Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 0.07),
                                      hintText: '6자리 숫자를 입력하세요',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(
                                        timerText,
                                        style: TextStyle(
                                          color: _remainingTime > 0
                                              ? Colors.black
                                              : Colors.red,
                                          fontSize: 16,
                                          fontFamily: 'Noto Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _buttonConfirmColor == Color(0xFFEC295D)
                          ? () async {
                        String smsCode = _confirmController.text;
                        if (smsCode.isNotEmpty &&
                            _verificationId.isNotEmpty) {
                          try {
                            firebase_auth.PhoneAuthCredential credential =
                            firebase_auth.PhoneAuthProvider.credential(
                                verificationId: _verificationId,
                                smsCode: smsCode);

                            final firebase_auth.UserCredential
                            userCredential =
                            await firebase_auth.FirebaseAuth.instance
                                .signInWithCredential(credential);

                            firebase_auth.User? user =
                                userCredential.user;

                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('인증 완료')));

                              bool registrationResult =
                              await registerParent(
                                  user.phoneNumber!);
                              if (registrationResult) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text(
                                        "회원가입 및 로그인 성공")));

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatTest(
                                          imagePath:
                                          'assets/sample.png',
                                          emotionImages: {},
                                        )));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text(
                                        "회원가입 실패, 다시 시도해주세요")));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "인증 실패: 사용자 정보가 없습니다.")));
                            }
                          } on firebase_auth.FirebaseAuthException catch (e) {
                            String errorMessage;
                            switch (e.code) {
                              case "invalid-verification-code":
                                errorMessage = '잘못된 인증번호입니다';
                                break;
                              case "invalid-verification-id":
                                errorMessage =
                                'verification ID of the credential is not valid.id';
                                break;
                              case "missing-verification-id":
                                errorMessage =
                                '인증번호가 전송되지 않았습니다. 재전송해주세요';
                                break;
                              case "user-disabled":
                                errorMessage = '계정이 비활성화되었습니다';
                                break;
                              case "operation-not-allowed":
                                errorMessage = '현재 로그인이 비활성화되었습니다';
                                break;
                              case "invalid-credential":
                                errorMessage =
                                '인증 시간이 만료되었습니다. 다시 시도해주세요';
                                break;
                              default:
                                errorMessage = '알 수 없는 오류가 발생했습니다';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "인증 실패: $errorMessage")));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("인증번호를 입력하세요.")));
                        }
                      }
                          : null,
                      style: TextButton.styleFrom(
                        minimumSize: Size(350, 52),
                        backgroundColor: _buttonConfirmColor,
                        foregroundColor: _textConfirmColor,
                        padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                width: 1, color: _buttonConfirmColor)),
                      ),
                      child: Text('인증 완료',
                          style: TextStyle(
                              color: _textConfirmColor,
                              fontSize: screenSize.width * 0.05,
                              fontFamily: 'Noto Sans',
                              fontWeight: FontWeight.w600,
                              height: 0.07)),
                    ),
                    SizedBox(height: 50),
                    Text(
                      '소셜 로그인하기',
                      style: TextStyle(
                          color: Colors.grey, // Light gray color
                          fontSize: screenSize.width * 0.04,
                          fontFamily: 'Noto Sans',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: IconButton(
                            icon: Image.asset('assets/google.png',
                                width: 25, height: 25),
                            onPressed: _loginWithGoogle,
                          ),
                        ),
                        SizedBox(width: 20), // Adjust the width value to control the spacing
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: IconButton(
                            icon: Image.asset('assets/naver.png', width: 25, height: 25),
                            onPressed: _loginWithNaver,
                          ),
                        ),
                        SizedBox(width: 20), // Adjust the width value to control the spacing
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: IconButton(
                            icon: Image.asset('assets/apple.png', width: 30, height: 30),
                            onPressed: _loginWithApple,
                          ),
                        ),
                        SizedBox(width: 20), // Adjust the width value to control the spacing
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: IconButton(
                            icon: Image.asset('assets/kakao.png', width: 25, height: 25),
                            onPressed: _loginWithKakao,
                          ),
                        ),
                      ],
                    )

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}