import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:taba_app_proj/firebase_options.dart';
// import 'package:calendar_scheduler/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 책에 있는 내용
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   await initializeDataFormatting();
//
//   final database = LocalDatabase();
//
//   GetIt.I.registerSingleton<LocalDatabase>(database);
//
//
// }

FirebaseAuth _auth = FirebaseAuth.instance;

void sendCode(String phoneNumber) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      // 자동 완성 처리: 사용자가 코드를 수동으로 입력할 필요 없이 자동 로그인
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      // 인증 실패 처리
      print('Verification Failed: ${e.message}');
    },
    codeSent: (String verificationId, int? resendToken) {
      // 코드가 전송된 후 처리, 예: 사용자에게 코드 입력 요청
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // 코드 자동 검색 타임아웃 처리
    },
  );
}

void verifyCode(String verificationId, String smsCode) async {
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );

  try {
    final user = await _auth.signInWithCredential(credential);
    // 인증 성공: user 객체를 사용하여 추가 작업 처리
  } catch (e) {
    // 인증 실패 처리
  }
}
