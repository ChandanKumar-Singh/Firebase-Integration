import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/routes/app_pages.dart';

//for background message action
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message:---------- ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .then((value) => print('Firebase App Initialised'));
  //initialize firebase messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
//get FCM token for this device
  var token = await messaging.getToken();
  print(
      '*************************************************************************************************************************************************************************************    $token*******************************************************************************************************************');

  //calls when token changes
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    // TODO: If necessary send token to application server.
    print(
        '************************************************************************************************************************************************************************************* New Token---   $fcmToken*******************************************************************************************************************');
    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    // Error getting token.
  });

  //an instance of FlutterLocalNotificationsPlugin.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //Represents the devices notification settings. and Prompts the user for notification permissions.
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  //on bg firebase message coming
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//an instance of AndroidNotificationChannel.
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  //Sets the presentation options for Apple notifications when received in the foreground.
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //Creates a notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(channel.id, channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_stat_android');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (str) =>
          print('0000000000000000000   $str    00000000000000000000000000'));
  //Returns a Stream that is called when an incoming FCM payload is received
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? remoteNotificatins = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (remoteNotificatins != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          remoteNotificatins.hashCode,
          remoteNotificatins.title,
          remoteNotificatins.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              // other properties...
            ),
          ));
    }
  });

  void _handleMessage(RemoteMessage message) {
    print('111111111111111111111111111111   $message');
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute:
          auth.currentUser == null ? AppPages.LOGIN : AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();

  void login() async {
    GoogleSignInAccount? account = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await account!.authentication;
    AuthCredential authCredential = await GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);

    await auth
        .signInWithCredential(authCredential)
        .then((value) => Get.offNamed('/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RaisedButton(
            onPressed: () {
              login();
            },
            child: Text('Login'),
          ),
        ),
      ),
    );
  }
}
