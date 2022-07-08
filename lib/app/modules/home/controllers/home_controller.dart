
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController


  @override
  void onInit() {
    super.onInit();

    setupInteractedMessage();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void logOut()async{
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Get.offNamed('/login');

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

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
     print(message);
    }
  }
}
