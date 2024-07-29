import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chatbot/chat_test.dart';

class FcmProvider with ChangeNotifier {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? token;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundPushSubscription;

  Future<void> initializeNotification(BuildContext context) async {
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    token = await fcm.getToken();
    if (token != null) {
      await saveToken();
    }

    _tokenRefreshSubscription = fcm.onTokenRefresh.listen((newToken) async {
      token = newToken;
      await saveToken();
    });

    await _firebaseMessagingForegroundHandler(context);
    notifyListeners();
  }

  Future<void> saveToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    if (accessToken == null) return;

    var url = Uri.parse('http://3.38.165.93:8080/api/v1/push/register');
    await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{'fcmToken': token ?? ''}),
    );
  }

  Future<void> _firebaseMessagingForegroundHandler(BuildContext context) async {
    RemoteMessage? initialMessage = await fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(context, initialMessage);
    }

    _foregroundPushSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isAndroid) showFlutterNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ChatTest(imagePath: 'assets/sample.png', emotionImages: {}),
      ),
    );
  }

  void showFlutterNotification(RemoteMessage message) {
    // Implement your local notification logic here
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundPushSubscription?.cancel();
    super.dispose();
  }
}
