import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Screen/HomePage/home.dart';
import '../Provider/settingProvider.dart';
import '../Screen/OrderDetail/OrderDetail.dart';
import '../Widget/api.dart';
import '../Widget/routes.dart';
import '../Widget/sharedPreferances.dart';
import '../Widget/parameterString.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

// Future<void> backgroundMessage(RemoteMessage message) async {
//
// }

class PushNotificationService {
  final BuildContext context;

  PushNotificationService({required this.context});

  Future initialise() async {
    permission();
    messaging.getToken().then(
      (token) async {
        SettingProvider settingProvider = Provider.of<SettingProvider>(context, listen: false);

        if (context.read<SettingProvider>().CUR_USERID != null &&
            context.read<SettingProvider>().CUR_USERID != "")
          _registerToken(token);
      },
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onDidReceiveNotificationResponse:
    //         (NotificationResponse notificationResponse) async {
    //   if (notificationResponse.payload != null) {
    //     List<String> pay = notificationResponse.payload!.split(',');
    //     if (pay[0] == 'order' || pay[1] != '') {
    //       Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //           builder: (context) => OrderDetail(
    //             id: pay[1],
    //           ),
    //         ),
    //       );
    //     } else {
    //       Routes.navigateToMyApp(context);
    //     }
    //   }
    // });
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('__________onMessage_________');
        var data = message.notification!;
        var title = data.title.toString();
        var body = data.body.toString();
        var image = message.data['image'] ?? '';
        var type = '';
        // var orderId = '';
        type = message.data['type'] ?? '';
        //orderId = message.data['order_id'] ?? '';

        if (image != null && image != 'null' && image != '') {
          generateImageNotication(title, body, image, type, );
        } else {
          generateSimpleNotication(title, body, type, );
        }
      },
    );


    messaging.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        print("notification message initial****${message.data.toString()}");
        var orderId = message.data['order_id'] ?? '';

        bool back = await getPrefrenceBool(iSFROMBACK);
        if (back) {
          if (orderId != '') {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => OrderDetail(
                  id: orderId,
                ),
              ),
            );
          } else {
            Routes.navigateToMyApp(context);
          }
        }
      }
    });

//==============================================================================
//========================= onMessageOpenedApp =================================
// when app is background

    // FirebaseMessaging.onMessageOpenedApp.listen(
    //   (RemoteMessage message) async {
    //     print(
    //         "notification message on message open app****${message.data.toString()}");
    //     var type = message.data['type'] ?? '';
    //     var orderId = message.data['order_id'] ?? '';
    //     if (orderId != '') {
    //       Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //           builder: (context) => OrderDetail(
    //             id: orderId,
    //           ),
    //         ),
    //       );
    //     } else {
    //       Routes.navigateToMyApp(context);
    //     }
    //
    //     setPrefrenceBool(iSFROMBACK, false);
    //   },
    // );
  }

  void permission() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,

    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerToken(String? token) async {
    var parameter = {
      'user_id': context.read<SettingProvider>().CUR_USERID,
      FCMID: token,
    };
    apiBaseHelper.postAPICall(updateFcmApi, parameter).then(
          (getdata) async {},
          onError: (error) {},
        );
  }

  static Future<String> _downloadAndSaveImage(
      String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));

    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  // Future<String> _downloadAndSaveImage(String url, String fileName) async {
  //   var directory = await getApplicationDocumentsDirectory();
  //   var filePath = '${directory.path}/$fileName';
  //   var response = await get(Uri.parse(url));
  //
  //   var file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }

  // Future<void> generateImageNotication(String title, String msg, String image,
  //     String type, String payload) async {
  //   var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  //   var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  //   var bigPictureStyleInformation = BigPictureStyleInformation(
  //       FilePathAndroidBitmap(bigPicturePath),
  //       hideExpandedLargeIcon: true,
  //       contentTitle: title,
  //       htmlFormatContentTitle: true,
  //       summaryText: msg,
  //       htmlFormatSummaryText: true);
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'big text channel id', 'big text channel name',
  //       channelDescription: 'big text channel description',
  //       icon: '@mipmap/ic_launcher',
  //       largeIcon: FilePathAndroidBitmap(largeIconPath),
  //       styleInformation: bigPictureStyleInformation,
  //       playSound: true,
  //       enableVibration: true,
  //       enableLights: true,
  //       sound: RawResourceAndroidNotificationSound('test')
  //   );
  //   var platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, title, msg, platformChannelSpecifics,
  //       payload: '$type,$payload');
  // }
  //
  // Future<void> generateSimpleNotication(
  //     String title, String msg, String type, String id) async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //       'high_importance_channel', 'High Importance Notifications',
  //       channelDescription: 'your channel description',
  //       importance: Importance.max,
  //       icon: '@mipmap/ic_launcher',
  //       priority: Priority.high,
  //       ticker: 'ticker',
  //       playSound: true,
  //       enableVibration: true,
  //       enableLights: true,
  //      sound: RawResourceAndroidNotificationSound('test')
  //   );
  //
  //   var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin
  //       .show(0, title, msg, platformChannelSpecifics, payload: type + "," + id);
  // }
  static Future<void> generateImageNotication(
      String title, String msg, String image,String type) async {
    print('__________surendra_________');
    var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(

        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        channelDescription:'big text channel description',
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        // playSound: true,
        // sound: RawResourceAndroidNotificationSound('test'),

        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, msg, platformChannelSpecifics,payload: type);
  }
  static Future<void> generateSimpleNotication(String title, String msg,String type) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_notification_channel', 'your channel name', channelDescription:'your channel description',
        importance: Importance.max, priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        sound: RawResourceAndroidNotificationSound('test'),
        ticker: 'ticker'
    );

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload:type );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}


