import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pinput/pinput.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/Constant.dart';
import 'package:sellermultivendor/Helper/PushNotificationService.dart';
import 'package:sellermultivendor/Screen/Authentication/Login.dart';
import 'package:sellermultivendor/Screen/DeshBord/dashboard.dart';
import 'package:sellermultivendor/Widget/sharedPreferances.dart';
import 'package:sellermultivendor/Widget/snackbar.dart';

import '../../Widget/parameterString.dart';
import '../HomePage/home.dart';


class OTPScreen extends StatefulWidget {
  String mobile,otp;


  OTPScreen(this.mobile,this.otp);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  List<String> method = ["Email", "Mobile No."];
  String selectMethod = "Email";
  TextEditingController mobileCon = TextEditingController();
  TextEditingController pinCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();
  bool obscure = true;
  final focusNode = FocusNode();
  AnimationController? buttonController;
  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = secondary;
    const fillColor =  lightWhite;
    const borderColor = lightWhite;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: getWidth(100, context),
                height: getHeight(10, context),
                decoration: BoxDecoration(
                    gradient: commonGradient(),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: const Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.white,
                      size: 32,
                    )),
                    SizedBox(width: 100),
                    Center(
                      child: Text(
                        //${widget.otp}
                        "Verification",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              boxHeight(3, context),
              getLogo(),
              Text(
                "Code has sent to",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!,
              ),
              Text(
                "+91${widget.mobile}",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!,
              ),
              boxHeight(3, context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Pinput(
                  controller: pinCon,
                  focusNode: focusNode,
                  length: 6,
                  androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
                  listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  autofocus: true,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
              ),
              boxHeight(3, context),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Haven't received the verification code?\n",
                    style: Theme.of(context).textTheme.titleMedium,
                    children: <TextSpan>[
                      TextSpan(text: ' Resend',
                          style:Theme.of(context).textTheme.titleMedium!.copyWith(color: secondary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                loading = true;
                              });
                              loginApi();
                              // navigate to desired screen
                            }
                      )
                    ]
                ),
              ),
              boxHeight(5, context),
              commonButton(
                onPressed: () {
                  if(pinCon.text==""||pinCon.text != widget.otp){
                    setSnackbar("Enter Valid OTP", context);
                    return;
                  }
                  setState(() {
                    loading = true;
                  });
                  verifyApi();
                },
                loading: loading,
                title:  "Verify",
                context: context,
              ),

            ],
          ),
        ),
      ),
    );
  }

  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  String? mobile, password, username, id,fId;
  bool loading = false;
  void verifyApi()async{
    try{
      Map param = {
        "mobile":widget.mobile,
        "otp":pinCon.text,
      };
      var response = await apiBaseHelper.postAPICall(Uri.parse("${baseUrl}verify_otp"), param);
      if(!response['error']){
        bool error = response["error"];
        String? msg = response["message"];
        // if(mounted) {
        //   setSnackbar(response['message'], context);
        //   print('_________vvbbvv_________');
        //
        // }
        var data = response["data"][0];
        id = data[Id];
        username = data[Username];
        mobile = data[Mobile];
                 print('__________${id}_________');
        saveUserDetail(id!, username!, mobile!,);
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

            var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
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
      }else{
        setSnackbar(response['message'], context);
      }
    }catch(e){
      setState(() {
        loading =false;
      });
    }finally{
      setState(() {
        loading =false;
      });
    }
  }
  void loginApi()async{
    try{
      Map param = {

      };
      param['mobile'] = widget.mobile;
      var response = await apiBaseHelper.postAPICall(Uri.parse("${baseUrl}send_otp"), param);
      setState(() {
        loading =false;
      });
      if(!response['error']){
        setState(() {
          widget.otp =  response['otp'].toString();
        });

      }else{
        setSnackbar(response['message'], context);
      }
    }catch(e){
      setState(() {
        loading =false;
      });
    }finally{
      setState(() {
        loading =false;
      });
    }
  }
  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child:  Image.asset("assets/images/PNG/loginlogo.png",  width: 150,
        height: 150,),
    );

  }
}
