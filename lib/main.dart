import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:taba_app_proj/chatbot/chat_test.dart';
import 'package:taba_app_proj/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taba_app_proj/screen/stastics.dart';
import 'package:taba_app_proj/screentime.dart';
import 'firebase_options.dart';
import 'package:taba_app_proj/screentime.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Future.delayed(duration)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: StatisticsScreen(),
      home: HomeScreen(),
    );
  }
}
