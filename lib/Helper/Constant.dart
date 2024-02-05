// add your constant file's

//Your application title
import 'package:flutter/material.dart';
import 'package:sellermultivendor/Helper/Color.dart';

const String title = 'Jetsetter India Restaurant Partner';

//Your application name
const String appName = 'Jetsetter India Restaurant Partner';

//Your package name
const String packageName = 'jetsetter.seller';
const String iosPackage = 'jetsetter.seller';

//Set country code
String defaultCountryCode = 'IN';

//Add your secret key here to conncet app with admin panel .
const String baseUrl = 'https://jetsetterindia.com/seller/app/v1/api/';
const String jwtKey = '';

//Time settings
const int timeOut = 50;

//loading page value
const int perPage = 10;

// issue name (Note : Please do not change this value)
const String issuerName = 'eshop';

//Bank detail hint text
const String BANK_DETAIL = 'Bank Details:';

//Radius
const double circularBorderRadius3 = 3;
const double circularBorderRadius5 = 5;
const double circularBorderRadius7 = 7;
const double circularBorderRadius8 = 8;
const double circularBorderRadius10 = 10;
const double circularBorderRadius12 = 12;
const double circularBorderRadius13 = 13;
const double circularBorderRadius15 = 15;
const double circularBorderRadius25 = 25;
const double circularBorderRadius30 = 30;
const double circularBorderRadius50 = 50;
const double circularBorderRadius100 = 100;

//FontSize
const double textFontSize9 = 9;
const double textFontSize10 = 10;
const double textFontSize12 = 12;
const double textFontSize13 = 13;
const double textFontSize14 = 14;
const double textFontSize15 = 15;
const double textFontSize16 = 16;
const double textFontSize18 = 18;
const double textFontSize20 = 20;
const double textFontSize23 = 23;
const double textFontSize25 = 25;
const double textFontSize30 = 30;
double getHeight(double height, BuildContext context) {
  double tempHeight = 0.0;
  tempHeight = ((height * 100) / 1290);
  return (MediaQuery.of(context).size.height * height) / 100;
}

double getWidth(double width, BuildContext context) {
  double tempWidth = 0.0;
  tempWidth = ((width * 100) / 720);
  return (MediaQuery.of(context).size.width * width) / 100;
}

Widget boxWidth(double width, BuildContext context) {
  return SizedBox(
    width: getWidth(width, context),
  );
}

Widget boxHeight(double height, BuildContext context) {
  return SizedBox(
    height: getHeight(height, context),
  );
}
Widget commonButton({String title = "Btn",bool loading = false,double width = 70,double height = 6,BuildContext? context,VoidCallback? onPressed}){
  return Container(
      height: getHeight(height, context!),
      width: getWidth(width, context!),
      decoration: BoxDecoration(
        gradient: commonGradient(),
        borderRadius: BorderRadius.circular(40),
      ),
      child:ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: !loading
            ? Text(
          title,
          style: Theme.of(context!).textTheme.headlineSmall!.copyWith(color: Colors.white),
        )
            : CircularProgressIndicator(
          color: Colors.white,
        ),
      )
  );
}
Gradient commonGradient(){
  return const LinearGradient(
    colors: [primary, secondary],
    stops: [0, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}