import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sellermultivendor/Screen/Authentication/otp_screen.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Helper/PushNotificationService.dart';
import '../Screen/Authentication/Login.dart';
import '../Screen/DeshBord/dashboard.dart';
import '../Widget/api.dart';
import '../Widget/parameterString.dart';
import '../Widget/sharedPreferances.dart';

class LoginProvider extends ChangeNotifier {
  String? mobile, password, username, id,fId;
  AnimationController? buttonController;

  get getMobilenumber => mobile;
  get getPassword => Password;
  Future<void> sendOTP(
      BuildContext context,
      GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
      Function updateNow,
      String? fId
      ) async {
    var data = {
      Mobile: mobile,
      //Password: password,
      'device_token':fId
    };
    ApiBaseHelper().postAPICall(getUserSendOtpApi, data).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setSnackbarScafold(scaffoldMessengerKey, context, msg!);
          String mobile = getdata["mobile"].toString();
          String otp = getdata["otp"].toString();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>   OTPScreen(mobile,otp),
            ),
          );
        } else {
          await buttonController!.reverse();
          setSnackbarScafold(scaffoldMessengerKey, context, msg!);
          updateNow();
        }
      },
      onError: (error) {
        setSnackbarScafold(scaffoldMessengerKey, context, error.toString());
      },
    );
  }
  Future<void> getLoginUser(

    BuildContext context,
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    Function updateNow,
      String? fId
  ) async {
    var data = {
      Mobile: mobile,
      Password: password,
      'fcm_id':fId
    };


    ApiBaseHelper().postAPICall(getUserLoginApi, data).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setSnackbarScafold(scaffoldMessengerKey, context, msg!);
          var data = getdata["data"][0];
          id = data[Id];
          username = data[Username];
          mobile = data[Mobile];
          saveUserDetail(
            id!,
            username!,
            mobile!,
          );
          setPrefrenceBool(isLogin, true);
              FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();
          FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            RemoteNotification? notification = message.notification;
            AndroidNotification? android = message.notification?.android;

            if (notification != null && android != null) {
              FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();

              var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  'your_channel_id', 'your_channel_name',
                  channelDescription: 'your_channel_description',
                  sound:  RawResourceAndroidNotificationSound('test'),
                  importance: Importance.max,
                  priority: Priority.high);

              var platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

              flutterLocalNotificationsPlugin.show(
                  0, notification.title, notification.body, platformChannelSpecifics);
            }
          });
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) =>  const Dashboard(),
            ),
          );
        } else {
          await buttonController!.reverse();
          setSnackbarScafold(scaffoldMessengerKey, context, msg!);
          updateNow();
        }
      },
      onError: (error) {
        setSnackbarScafold(scaffoldMessengerKey, context, error.toString());
      },
    );
  }
}
