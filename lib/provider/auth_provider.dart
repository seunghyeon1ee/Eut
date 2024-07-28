import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(
      BuildContext context, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to Verify Phone Number: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Verification Code Sent")));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle code auto retrieval timeout
      },
    );
  }
}

