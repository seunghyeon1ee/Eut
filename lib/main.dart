import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:taba_app_proj/chatbot/chat_test.dart';
import 'package:taba_app_proj/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taba_app_proj/screen/stastics.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
        home: HomeScreen(),
    ),
  );
}



