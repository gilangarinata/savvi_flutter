import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/ui/splashscreen/splash_screen.dart';
import 'package:mylamp_flutter_v4_stable/utils/PushNotificationManager.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'dart:convert';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlavorEnvironment environment = FlavorEnvironment.PROD;
  FlavorConfig(
    environment: environment,
    location: BannerLocation.bottomEnd,
    variables: MyVariables().myVars(environment),
  );

  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String dataName = '';
  static String dataAge = '';
  final firebaseMessaging = FirebaseMessaging();
  final controllerTopic = TextEditingController();
  bool isSubscribed = false;
  String token = '';

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage: $message');
    if (message.containsKey('data')) {
      String name = '';
      String age = '';
      if (Platform.isIOS) {
        name = message['name'];
        age = message['age'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        name = data['name'];
        age = data['age'];
      }
      dataName = name;
      dataAge = age;
      debugPrint('onBackgroundMessage: name: $name & age: $age');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        try{
          var _list = message.values.toList();
          showDialog(context: navigatorKey.currentContext ,builder: (_) => CustomEventDialog(message: _list[0].toString(),) );
        }catch(e){
          debugPrint('error  : $e');
        }
        debugPrint('onMessage: $message');
        getDataFcm(message);
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume: $message');
        getDataFcm(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch: $message');
        getDataFcm(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered: $settings');
    });
    firebaseMessaging.getToken().then((token) => setState(() {
      this.token = token;
    }));
  }

  void getDataFcm(Map<String, dynamic> message) {
    String name = '';
    String age = '';
    if (Platform.isIOS) {
      name = message['name'];
      age = message['age'];
    } else if (Platform.isAndroid) {
      var data = message['data'];
      name = data['name'];
      age = data['age'];
    }
    if (name.isNotEmpty && age.isNotEmpty) {
      setState(() {
        dataName = name;
        dataAge = age;
      });
    }
    debugPrint('getDataFcm: name: $name & age: $age');
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey:  navigatorKey,
      theme: ThemeData(primaryColor: Colors.white, accentColor: MyColors.primary),
      home: SplashScreen(),
    );
  }
}



class CustomEventDialog extends StatefulWidget {

  CustomEventDialog({Key key, this.message}) : super(key: key);

  String message;


  @override
  CustomEventDialogState createState() => new CustomEventDialogState();
}

class CustomEventDialogState extends State<CustomEventDialog>{

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(width: 160,
        child: Card(
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),),
          color: Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Wrap(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                width : double.infinity, color: Colors.red[400],
                child: Column(
                  children: <Widget>[
                    Container(height: 10),
                    Icon(Icons.notification_important, color: Colors.white, size: 80),
                    Container(height: 10),
                    Text(MyStrings.notification, style: MyText.title(context).copyWith(color: Colors.white)),
                    Container(height: 10),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                width : double.infinity,
                child: Column(
                  children: <Widget>[
                    Text(widget.message, textAlign : TextAlign.center, style: MyText.subhead(context).copyWith(color: MyColors.grey_60)),
                    Container(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}