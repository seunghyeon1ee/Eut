import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:taba_app_proj/chatbot/chat_test.dart';
import 'package:taba_app_proj/screen/register_elder_fin.dart';
import 'package:taba_app_proj/screen/register_fam_1.dart';
import 'package:taba_app_proj/screen/register_fam_fin.dart';

import '../controller/fcm_controller.dart';

import 'package:responsive_builder/responsive_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  get imageItems => null;

  get index => null;

  @override
  void initState() {
    // TODO: implement initState
    FcmController.instance.initializeNotification();
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('A new onMessageOpenedApp event was published!');
      await Get.to(ChatTest(
        imagePath: imageItems[index].imagePath,
        emotionImages: imageItems[index].emotionImages,
      ));

    });
  }

  /// 앱 종료시 로컬 푸시를 클릭해 앱을 켰는지 체크
  Future<void> _listenerWithTerminated() async {
    FlutterLocalNotificationsPlugin localNotification =
        FlutterLocalNotificationsPlugin();

    NotificationAppLaunchDetails? details =
        await localNotification.getNotificationAppLaunchDetails();
    if (details != null) {
      if (details.didNotificationLaunchApp) {
        debugPrint(
            'did Notification Launch App: ${details.notificationResponse?.payload}');

        Get.to(ChatTest( imagePath: imageItems[index].imagePath,
          emotionImages: imageItems[index].emotionImages,));

        if (details.notificationResponse?.payload != null) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ScreenTypeLayout.builder(
            mobile: (BuildContext context) => buildMobileLayout(context),
            tablet: (BuildContext context) => buildTabletLayout(context),
            desktop: (BuildContext context) => buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 100),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icon_eut.svg',
                ),
              ],
            ),
            const SizedBox(height: 50),
            const Row(
              children: [
                SizedBox(width: 15.0, height: 50.0),
                Text(
                  '환영합니다!',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      height: 0.06),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 15.0, height: 100.0),
                Text(
                  '이웃이 있으면 가깝고, 웃음이 있으면 밝고\n이웃을 지금 시작해보세요!',
                  style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp2()),
                );
              },
              highlightColor: Colors.white30,
              borderRadius: BorderRadius.circular(10),
              child: Center(
                  child: Ink(
                    width: 350,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            colors: [Color(0xFFEC295D), Color(0xFFFF7672)])),
                    child: Center(
                      child: Text(
                        '시작하기',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w600,
                            height: 0.07),
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: 15.0),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisFam()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(350, 52), // width: 200, height: 60
                  padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Color(0xFFE2E2E2), width: 1),
                ),
                child: Text(
                  '가족으로 시작하기',
                  style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 14,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      height: 0.09),
                ),
              ),
            ),
            SizedBox(height: 60),
          ],
        )
      ],
    );
  }

  Widget buildTabletLayout(BuildContext context) {
    return buildMobileLayout(context); // 간단히 모바일 레이아웃을 재사용
  }

  Widget buildDesktopLayout(BuildContext context) {
    return buildMobileLayout(context);
  }
}
