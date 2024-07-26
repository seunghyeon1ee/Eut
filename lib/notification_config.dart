part of 'main.dart';

/// Working example of FirebaseMessaging.
/// Please use this in order to verify messages are working in foreground, background & terminated state.
/// Setup your app following this guide:
/// https://firebase.google.com/docs/cloud-messaging/flutter/client#platform-specific_setup_and_requirements):
///
/// Once you've completed platform specific requirements, follow these instructions:
/// 1. Install melos tool by running `flutter pub global activate melos`.
/// 2. Run `melos bootstrap` in FlutterFire project.
/// 3. In your terminal, root to ./packages/firebase_messaging/firebase_messaging/example directory.
/// 4. Run `flutterfire configure` in the example/ directory to setup your app with your Firebase project.
/// 5. Run the app on an actual device for iOS, android is fine to run on an emulator.
/// 6. Use the following script to send a message to your device: scripts/send-message.js. To run this script,
///    you will need nodejs installed on your computer. Then the following:
///     a. Download a service account key (JSON file) from your Firebase console, rename it to "google-services.json" and add to the example/scripts directory.
///     b. Ensure your device/emulator is running, and run the FirebaseMessaging example app using `flutter run`.
///     c. Copy the token that is printed in the console and paste it here: https://github.com/firebase/flutterfire/blob/01b4d357e1/packages/firebase_messaging/firebase_messaging/example/lib/main.dart#L32
///     c. From your terminal, root to example/scripts directory & run `npm install`.
///     d. Run `npm run send-message` in the example/scripts directory and your app will receive messages in any state; foreground, background, terminated.
///  Note: Flutter API documentation for receiving messages: https://firebase.google.com/docs/cloud-messaging/flutter/receive
///  Note: If you find your messages have stopped arriving, it is extremely likely they are being throttled by the platform. iOS in particular
///  are aggressive with their throttling policy.
///
/// To verify that your messages are being received, you ought to see a notification appearon your device/emulator via the flutter_local_notifications plugin.
/// Define a top-level named handler which background/terminated messages will
/// call. Be sure to annotate the handler with `@pragma('vm:entry-point')` above the function declaration.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  debugPrint("background message: ${message.toMap()}");

  /// 1. Android
  /// notification이 있으면 메시지 수신되고 FCM 백그라운드 알림 뜸
  /// notification이 없으면 메시지 수신되고 FCM 알림이 안뜨므로 data로 로컬 노티 생성
  /// 뭔가 빈 알림(messageId가 없음)이 들어올때는 로컬 노티 띄우면 안됨
  // 참고: fcm 알림은 android large icon 지원 안됨

  if (message.notification == null && message.messageId != null) {
    showFlutterNotification(message);
  }
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // debugPrint('Handling a background message ${message.messageId}');
}

void onSelectNotification(NotificationResponse notificationResponse) async {
  /// 로컬 푸시가 클릭됨
  /// 여기서 페이로드는 로컬 푸시 띄울 때 등록한 페이로드
  debugPrint('push notification clicked!');
  Get.to(ChatTest(
    imagePath: imageItems[index].imagePath,
    emotionImages: imageItems[index].emotionImages,
  ));

  if (notificationResponse.payload != null &&
      notificationResponse.payload.toString().isNotEmpty) {
    final Map<String, dynamic> payload =
        jsonDecode(notificationResponse.payload!);
    debugPrint('notificaiton payload: $payload');
  }
  //밑에 푸시 알림 액션 구현
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

///Local Notificaion 초기화
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    enableVibration: true,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///플랫폼 별 초기화
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon'); //res/drawable/ 에 아이콘.png 만들어야함
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    //퍼미션 리퀘스트 따로하기 위해서 false
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    // onDidReceiveLocalNotification: onDidReceiveLocalNotification
    notificationCategories: [
      //ios는 푸시알림 카테고리를 미리 정의해야 함
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
    //로컬 푸시 알림 클릭 액션 설정
    onDidReceiveNotificationResponse: onSelectNotification,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

///Custom notifications for Android foreground
///notification에 title, body가 있으면
///data의 title, body를 대체시킨다
/// 로컬 노티 클릭 시 payload를 전달할 수 있다.
void showFlutterNotification(RemoteMessage message) {
  debugPrint("run showFlutterNotification");
  RemoteNotification? notification = message.notification;
  Map<String, dynamic>? data = message.data;
  // AndroidNotification? android = message.notification?.android;
  if (true) {
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
          // actions: <AndroidNotificationAction>[
          //   AndroidNotificationAction(
          //       'id_1', data["key_1"] ?? '',
          //   ),
          //   AndroidNotificationAction('id_2', data["key_2"] ?? ''),
          //   AndroidNotificationAction('id_3', 'Action 3'),
          // ],
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
        ),
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          //subtitle: 'the subtitle',
          //sound: 'slow_spring_board.aiff',
        ),
      ),

      /// 페이로드 "data: {title, body, pushType, referenceValue? }"
      /// 사용시 디코딩해서 추출
      payload: jsonEncode(data),
      // payload: message?.data as String,
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
