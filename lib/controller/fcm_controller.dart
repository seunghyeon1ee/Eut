//todo : 이 코드 대신에 fcm_provider를 만들어 준건데,, 혹시 몰라서 남겨는 둠
//todo: 근데 또 밑에 home_screen을 fcm_provider로 구현하려니까 어려워서..그냥 두고 얘로 함
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chatbot/chat_test.dart';
import '../main.dart';

class FcmController extends GetxController {
  static FcmController get instance => Get.find();

  final fcm = FirebaseMessaging.instance;
  late String? token;
  late StreamSubscription<String> _tokenRefreshSubscription;
  late StreamSubscription<RemoteMessage> _foregroundPushSubscription;

  @override
  void onInit() async {
    super.onInit();
    // fcm 초기화
    fcm.setAutoInitEnabled(true);
  }

  ///FCM 초기화 runApp 이후 호출
  void initializeNotification() async {
    debugPrint('Fcm initializeNotification');
    //알림 권한 요청
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // 토큰 발급
    debugPrint(
        'User granted fcm notification permission: ${settings.authorizationStatus}');
    fcm.getToken().then((token) async {
      debugPrint("get FCM token : ${token ?? 'token NULL!'}");
      if (token != null) {
        // FCM 토큰을 서버에 저장 👈👈👈👈👈👈👈👈👈👈👈
        // if(token != null) m.updateFcmToken(l.getUser().value.uid, token);
        this.token = token;
        // saveToken(token);
      }
      // client.post(Uri.parse(Constants.API + 'booster/v1/fcm-token'), body: jsonEncode({ 'fcmToken': "$token" }));
    });

    // 토큰 리프레시 리스너 등록
    _tokenRefreshSubscription = fcm.onTokenRefresh.listen((newToken) async {
      debugPrint("on refresh FCM token : $newToken");
      // TODO: If necessary send token to application server.
      token = newToken;
      // saveToken(newToken);
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }, onDone: () {
      _tokenRefreshSubscription.cancel();
    }, onError: (e) {});
    // 포어그라운드 푸시 리스너 등록
    await _firebaseMessagingForegroundHandler();
  }

  Future<void> saveToken() async {
    final refs = await SharedPreferences.getInstance();
    String? accessToken = refs.getString('access_token');
    print('accessToken: $accessToken');

    var url = Uri.parse(
        'http://3.38.165.93:8080/api/v1/push/register'); // API 엔드포인트 URL
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{'fcmToken': token ?? ''}),
    );

    print(response.body);
  }

  /// 포어 그라운드 푸시 알림 처리
  Future<void> _firebaseMessagingForegroundHandler() async {
    RemoteMessage? initialMessage = await fcm.getInitialMessage();
    //
    if (initialMessage != null) {
      debugPrint('initial message exist: ${initialMessage.toMap()}');
      _handleMessage(initialMessage);
    }

    ///파이어 베이스 포어 그라운드 푸시 알림 처리
    _foregroundPushSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          /// IOS
          /// 포어에서 notification 이 없거나 null이거나 비어있으면 리스너에서 수신 못함
          /// notification: {title 또는 body} 가 있어야함
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message: ${message.toMap()}');

          /// 안드로이드
          /// 애는 notification이 없어도 리스너 수신 함
          /// 포어에서는 FCM으로 못열기 때문에 메세지를 로컬 노티로 열어줌
          if (Platform.isAndroid) showFlutterNotification(message);
        }, onDone: () {
          _foregroundPushSubscription.cancel();
        }, onError: (e) {});

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  ///FCM 푸시 클릭 핸들링
  void _handleMessage(RemoteMessage message) async {
    debugPrint("in handleMessage : ${message.toMap()}");
    Get.to(ChatTest(imagePath: 'assets/sample.png',
      emotionImages: {},));
    if (message.data['pushType'] != null &&
        message.data['pushType'].toString().isNotEmpty) {
      // if (message.data['referenceValue'] != null) {
      //   // 상세 페이지 id가 있는 경우 (공지사항, 이벤트 페이지)
      //   await webViewController.evaluateJavascript(
      //       source:
      //           "pushTypeHandler('${message.data['pushType']}', '${message.data['referenceValue']}');");
      // } else {
      //   await webViewController.evaluateJavascript(
      //       source: "pushTypeHandler('${message.data['pushType']}', '');");
      // }
    }
  }

  /// ios badge 초기화
  void initBadgeCount() async {
    // if (await FlutterAppBadger.isAppBadgeSupported()) {
    //   FlutterAppBadger.removeBadge();
    // }
  }
}