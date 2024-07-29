import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _accessToken;
  String? _verificationId;

  String? get accessToken => _accessToken;
  String? get verificationId => _verificationId;

  void setAccessToken(String? token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token!);
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(
      BuildContext context, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        final User? user = _auth.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          // setAccessToken(token);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to Verify Phone Number: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        notifyListeners();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Verification Code Sent")));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        notifyListeners();
      },
    );
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await _auth.signInWithCredential(credential);
      final User? user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        // setAccessToken(token);
      }
    } catch (e) {
      print('Verification Failed: $e');
    }
  }
}
