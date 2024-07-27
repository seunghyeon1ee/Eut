import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taba_app_proj/screen/register_elder_fin.dart';


class Authentic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LogInElder2();
  }
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
