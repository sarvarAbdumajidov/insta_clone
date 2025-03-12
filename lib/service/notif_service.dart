import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  static Future<void> init() async {
    // Notification
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications',
      importance: Importance.max,
    );

    var initAndroidSetting = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var initIosSetting = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(
      iOS: initIosSetting,
      android: initAndroidSetting,
    );

    await FlutterLocalNotificationsPlugin().initialize(
      initSetting,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}
