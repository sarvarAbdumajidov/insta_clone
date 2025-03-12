import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:insta_clone_first/service/pref_service.dart';

class Utils {
  static Future<void> showLocalNotification(String title, String body) async {
    var android = const AndroidNotificationDetails(
      "channelId",
      "channelName",
      channelDescription: "channelDescription",
    );
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android,iOS: iOS);

    int id = Random().nextInt((pow(2,31) - 1).toInt());
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }

  static void fireToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static Future<Map<String, dynamic>> deviceParams() async {
    Map<String, dynamic> params = {};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fcmToken = await PrefService.loadFCM();

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      params.addAll({
        'device_id': iosInfo.identifierForVendor, // iOS uchun unikal ID
        'device_type': 'I',
        'device_token': fcmToken,
      });
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      params.addAll({
        'device_id': androidInfo.id, // Android uchun unikal ID
        'device_type': 'A',
        'device_token': fcmToken,
      });
    }

    return params;
  }

  static String currentDate() {
    DateTime now = DateTime.now();
    String convertDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString()}:${now.minute.toString()}";
    return convertDateTime;
  }

  static Future<bool> dialogCommon(
    BuildContext context,
    String title,
    String message,
    bool isSingle,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            !isSingle
                ? MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel'),
                )
                : SizedBox.shrink(),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
