import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone_first/pages/siginin_page.dart';
import 'package:insta_clone_first/service/auth_service.dart';
import 'package:insta_clone_first/service/log_service.dart';

import '../service/pref_service.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  static const String id = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  _initTimer() {
    Timer(Duration(seconds: 2), () {
      _callNextPage();
    });
  }

  _callNextPage() {
    if (AuthService.isLoggedIn()) {
      _callHomePage();
    } else {
      _callSignInPage();
    }
  }

  _initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.d('User granted permission');
    } else {
      LogService.d('User declined or has not accepted permission');
    }
    _firebaseMessaging.getToken().then((token)async{
      String fcmToken = token!.toString();
      PrefService.saveFCM(fcmToken);
      String tokenFcm = await PrefService.loadFCM();
      LogService.i("FCM TOKEN:  $tokenFcm");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
    String title = message.notification!.title.toString();
    String body = message.notification!.body.toString();
    LogService.i(title);
    LogService.i(body);
    LogService.i(message.data.toString());
      //
    });
  }

  _callSignInPage() {
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  _callHomePage() {
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  @override
  void initState() {
    _initNotification();
    _initTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFCAF45), Color(0xFFF56040)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Insta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontFamily: 'Billabong',
                    ),
                  ),
                ),
              ),
              Text(
                'All rights reserved',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
