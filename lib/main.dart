import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taba_app_proj/provider/fcm_provider.dart';
import 'package:taba_app_proj/screen/home_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:taba_app_proj/screen/stastics.dart';
import 'controller/fcm_controller.dart';
import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'provider/greeting.dart';
import 'provider/create_image_provider.dart';
import 'chatbot/chat_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // 추가

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  await initServices();

  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');

  try {
    await dotenv.load(fileName: ".env"); // 추가
    String? kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY']; // 추가
    if (kakaoNativeAppKey != null) {
      KakaoSdk.init(nativeAppKey: kakaoNativeAppKey); // 추가
    } else {
      print("KAKAO_NATIVE_APP_KEY is not set in .env file");
    }
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GreetingProvider()),
        ChangeNotifierProvider(create: (_) => CreateImageProvider()),
        ChangeNotifierProvider(create: (_) => FcmProvider()),
      ],
      child: App(accessToken: accessToken),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, this.accessToken});
  final String? accessToken;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
            return HomeScreen();
          } else if (sizingInformation.deviceScreenType ==
              DeviceScreenType.tablet) {
            return HomeScreen(accessToken: accessToken);
          } else {
            return HomeScreen(accessToken: accessToken);
          }
        },
      ),
    );
  }
}

Future<void> initServices() async {
  debugPrint('starting services ...');
  await Get.putAsync(() => GetService().init());
  debugPrint('All services started...');
}

class GetService extends GetxService {
  Future<GetService> init() async {
    Get.put(GetConnect(), permanent: true);
    Get.put(FcmController(), permanent: true);
    return this;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  debugPrint("background message: ${message.toMap()}");

  if (message.notification == null && message.messageId != null) {
    showFlutterNotification(message);
  }
}

void onSelectNotification(NotificationResponse notificationResponse) async {
  debugPrint('push notification clicked!');
  Get.to(ChatTest(imagePath: 'assets/neutral.png', emotionImages: {}));
  if (notificationResponse.payload != null &&
      notificationResponse.payload.toString().isNotEmpty) {
    final Map<String, dynamic> payload =
    jsonDecode(notificationResponse.payload!);
    debugPrint('notification payload: $payload');
  }
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    enableVibration: true,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    notificationCategories: [
      DarwinNotificationCategory(
        'demoCategory',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            'id_3',
            'Action 3',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ],
  );
  final LinuxInitializationSettings initializationSettingsLinux =
  LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onSelectNotification,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  debugPrint("run showFlutterNotification");
  RemoteNotification? notification = message.notification;
  Map<String, dynamic>? data = message.data;

  flutterLocalNotificationsPlugin.show(
    notification?.hashCode ?? data.hashCode,
    notification?.title ?? data['title'],
    notification?.body ?? data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: 'app_icon',
        color: const Color(0x00ffdf16),
        largeIcon: const DrawableResourceAndroidBitmap("@drawable/app_icon"),
      ),
      iOS: DarwinNotificationDetails(
        badgeNumber: 1,
      ),
    ),
    payload: jsonEncode(data),
  );
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
