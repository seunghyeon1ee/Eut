// part of 'main.dart';
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await setupFlutterNotifications();
//   debugPrint("background message: ${message.toMap()}");
//
//   if (message.notification == null && message.messageId != null) {
//     showFlutterNotification(message);
//   }
// }
//
// void onSelectNotification(NotificationResponse notificationResponse) async {
//   debugPrint('push notification clicked!');
//   Get.to(ChatTest(imagePath: 'assets/neutral.png', emotionImages: {}));
//   if (notificationResponse.payload != null &&
//       notificationResponse.payload.toString().isNotEmpty) {
//     final Map<String, dynamic> payload = jsonDecode(notificationResponse.payload!);
//     debugPrint('notification payload: $payload');
//   }
// }
//
// late AndroidNotificationChannel channel;
// bool isFlutterLocalNotificationsInitialized = false;
//
// Future<void> setupFlutterNotifications() async {
//   if (isFlutterLocalNotificationsInitialized) {
//     return;
//   }
//   channel = const AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//     enableVibration: true,
//   );
//
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('app_icon');
//   final DarwinInitializationSettings initializationSettingsDarwin =
//   DarwinInitializationSettings(
//     requestSoundPermission: false,
//     requestBadgePermission: false,
//     requestAlertPermission: false,
//     notificationCategories: [
//       DarwinNotificationCategory(
//         'demoCategory',
//         actions: <DarwinNotificationAction>[
//           DarwinNotificationAction.plain('id_1', 'Action 1'),
//           DarwinNotificationAction.plain(
//             'id_2',
//             'Action 2',
//             options: <DarwinNotificationActionOption>{
//               DarwinNotificationActionOption.destructive,
//             },
//           ),
//           DarwinNotificationAction.plain(
//             'id_3',
//             'Action 3',
//             options: <DarwinNotificationActionOption>{
//               DarwinNotificationActionOption.foreground,
//             },
//           ),
//         ],
//         options: <DarwinNotificationCategoryOption>{
//           DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
//         },
//       ),
//     ],
//   );
//   final LinuxInitializationSettings initializationSettingsLinux =
//   LinuxInitializationSettings(defaultActionName: 'Open notification');
//   final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//       macOS: initializationSettingsDarwin,
//       linux: initializationSettingsLinux);
//
//   flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: onSelectNotification,
//     onDidReceiveBackgroundNotificationResponse: onSelectNotification,
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   isFlutterLocalNotificationsInitialized = true;
// }
//
// void showFlutterNotification(RemoteMessage message) {
//   debugPrint("run showFlutterNotification");
//   RemoteNotification? notification = message.notification;
//   Map<String, dynamic>? data = message.data;
//
//   flutterLocalNotificationsPlugin.show(
//     notification?.hashCode ?? data.hashCode,
//     notification?.title ?? data['title'],
//     notification?.body ?? data['body'],
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         channel.id,
//         channel.name,
//         channelDescription: channel.description,
//         importance: Importance.max,
//         priority: Priority.high,
//         ticker: 'ticker',
//         icon: 'app_icon',
//         color: const Color(0x00ffdf16),
//         largeIcon: const DrawableResourceAndroidBitmap("@drawable/app_icon"),
//       ),
//       iOS: DarwinNotificationDetails(
//         badgeNumber: 1,
//       ),
//     ),
//     payload: jsonEncode(data),
//   );
// }
//
// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
