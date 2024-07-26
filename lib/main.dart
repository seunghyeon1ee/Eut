import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taba_app_proj/chatbot/chat_test.dart';
import 'package:taba_app_proj/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taba_app_proj/screen/register_elder_fin.dart';
import 'package:taba_app_proj/screen/register_fam_fin.dart';
import 'package:taba_app_proj/screen/stastics.dart';
import 'package:taba_app_proj/screentime.dart';
import 'chatbot/chat1.dart';
import 'chatbot/select_image.dart';
import 'controller/fcm_controller.dart';
import 'firebase_options.dart';
import 'package:taba_app_proj/screentime.dart';
import 'package:responsive_builder/responsive_builder.dart';

part 'notification_config.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Future.delayed(duration)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ***파이어 베이스 메세징 백그라운드 핸들러는 최상위에 위치***
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  // 앱 수직 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 앱 상태바 활성화
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  // 앱 상태바 스타일
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // ios 상태바 모드
    statusBarBrightness: Brightness.light,
  ));

  await initServices();

  final refs = await SharedPreferences.getInstance();
  String? accessToken = refs.getString('access_token');
  runApp(App(accessToken: accessToken));
}

class App extends StatelessWidget {
  const App({super.key, this.accessToken});
  final String? accessToken;
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // home: StatisticsScreen(),
      home: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
            return MyApp2();
          } else if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return HomeScreen(accessToken: accessToken);
          } else {
            return HomeScreen(accessToken: accessToken); // 다른 레이아웃을 원할 경우 수정
          }
        },
      ),
      //HomeScreen(accessToken: accessToken),
      //homescreen 대신 다른 이미지들 넣어서 확인
    );
  }
}

Future<void> initServices() async {
  debugPrint('starting services ...');
  await Get.putAsync(() => GetService().init());
  // DynamicLinks().setup(); // 2025 deprecate
  debugPrint('All services started...');
}

class GetService extends GetxService {
  Future<GetService> init() async {
    Get.put(GetConnect(), permanent: true);
    Get.put(FcmController(), permanent: true);
    return this;
  }
}
